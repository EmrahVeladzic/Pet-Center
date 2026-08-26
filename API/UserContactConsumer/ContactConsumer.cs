using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using UserContactConsumer.Services;
using PetCenterShared;

public class RabbitMQCfg
{
    public string? hostname { get; set; }
    public string? queue { get; set; }
    public string? user { get; set; }
    public string? password { get; set; }

    public void Validate()
    {
        List<string> missing = [];
        if (string.IsNullOrWhiteSpace(hostname)) missing.Add("RabbitMQ:HostName");
        if (string.IsNullOrWhiteSpace(queue)) missing.Add("RabbitMQ:QueueName");
        if (string.IsNullOrWhiteSpace(user)) missing.Add("RabbitMQ:UserName");
        if (string.IsNullOrWhiteSpace(password)) missing.Add("RabbitMQ:Password");

        if (missing.Count > 0)
        {
            throw new InvalidOperationException(
                $"Missing required configuration: {string.Join(", ", missing)}.");
        }
    }
}

public class ContactConsumer
{
    private const ushort PrefetchCount = 5;

    private readonly IConfiguration cfg;
    private readonly ILogger logger;
    private readonly EmailService email_service;
    private readonly RabbitMQCfg rabbitmq;

    private IChannel? channel;
    private IConnection? connection;

    public ContactConsumer(IConfiguration c, EmailService e, ILogger _logger)
    {
        cfg = c;
        logger = _logger;
        email_service = e;

        IConfigurationSection rabbitmq_cfg = cfg.GetSection("RabbitMQ");

        rabbitmq = new()
        {
            hostname = rabbitmq_cfg["HostName"],
            queue = rabbitmq_cfg["QueueName"],
            user = rabbitmq_cfg["UserName"],
            password = rabbitmq_cfg["Password"]
        };

        rabbitmq.Validate();
    }

    public static async Task<ContactConsumer> CreateAsync(IConfiguration c, EmailService e, ILogger _logger)
    {
        ContactConsumer consumer = new(c, e, _logger);

        ConnectionFactory factory = new()
        {
            HostName = consumer.rabbitmq.hostname!,
            UserName = consumer.rabbitmq.user!,
            Password = consumer.rabbitmq.password!,
            AutomaticRecoveryEnabled = true,
            TopologyRecoveryEnabled = true
        };

        bool repeat = true;

        while (repeat)
        {
            try
            {
                repeat = false;

                consumer.connection = await factory.CreateConnectionAsync();
                consumer.channel = await consumer.connection.CreateChannelAsync();

                await RabbitTopology.DeclareAsync(consumer.channel, consumer.rabbitmq.queue!);

                await consumer.channel.BasicQosAsync(0, PrefetchCount, global: false);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not connect to the broker, retrying in 5s.");
                repeat = true;
                await Task.Delay(5000);
            }
        }

        return consumer;
    }

    public async Task StopAsync()
    {
        if (channel != null)
        {
            await channel.DisposeAsync();
            channel = null;
        }

        if (connection != null)
        {
            await connection.DisposeAsync();
            connection = null;
        }
    }

    public async Task StartListening()
    {
        if (channel == null)
        {
            throw new InvalidOperationException("Call CreateAsync before StartListening.");
        }

        AsyncEventingBasicConsumer consumer = new(channel);

        consumer.ReceivedAsync += async (sender, input) =>
        {
            ConsumerMessage? msg;

            try
            {
                string json = Encoding.UTF8.GetString(input.Body.ToArray());
                msg = JsonSerializer.Deserialize<ConsumerMessage>(json);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Malformed message body, routing to the dead-letter queue.");
                await channel.BasicNackAsync(input.DeliveryTag, false, requeue: false);
                return;
            }

            if (msg is null || string.IsNullOrWhiteSpace(msg.Contact))
            {
                logger.LogError("Message has no contact, routing to the dead-letter queue.");
                await channel.BasicNackAsync(input.DeliveryTag, false, requeue: false);
                return;
            }

            int delay = 1000;
            const int maxRetries = 3;

            for (int attempt = 0; attempt < maxRetries; attempt++)
            {
                try
                {
                    await email_service.SendEmail(msg.Contact, msg.Message, msg.Subject, msg.Name);

                    await channel.BasicAckAsync(input.DeliveryTag, false);
                    logger.LogInformation("Message acked successfully on attempt {Attempt}.", attempt + 1);
                    break;
                }
                catch (PermanentDeliveryException ex)
                {
                    logger.LogCritical(ex,
                        "Permanent delivery failure, routing to the dead-letter queue. Contact: {Contact}",
                        msg.Contact);
                    await channel.BasicNackAsync(input.DeliveryTag, false, requeue: false);
                    break;
                }
                catch (Exception ex)
                {
                    logger.LogError(ex,
                        "Delivery failed on attempt {Attempt} of {Max}. Retrying in {Delay}ms.",
                        attempt + 1, maxRetries, delay);

                    if (attempt < maxRetries - 1)
                    {
                        await Task.Delay(delay);
                        delay = Math.Min(delay * 2, 15000);
                    }
                    else
                    {
                        logger.LogError(ex,
                            "Exhausted all {Max} attempts, routing to the dead-letter queue.", maxRetries);

                        await channel.BasicNackAsync(input.DeliveryTag, false, requeue: false);
                    }
                }
            }
        };

        await channel.BasicConsumeAsync(
            queue: rabbitmq.queue!,
            autoAck: false,
            consumer: consumer);
    }
}