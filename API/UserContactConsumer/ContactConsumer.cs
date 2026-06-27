using Microsoft.Extensions.Configuration;
using MimeKit;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using UserContactConsumer.Services;
using PetCenterShared;
using System.Text.Json;
using System.ComponentModel.DataAnnotations;
using Microsoft.Extensions.Logging;

public class RabbitMQCfg
{
    public string? hostname {  get; set; }
    public string? queue {  get; set; }
    public string? user { get; set; }
    public string? password { get; set; }
}
public class ContactConsumer
{
    private readonly IConfiguration cfg;

    private readonly ILogger logger;
    private IChannel? channel;
    private readonly EmailService email_service;
    private readonly RabbitMQCfg rabbitmq;
    private IConnection? connection;

    public ContactConsumer(IConfiguration c, EmailService e, ILogger _logger)
    {
        cfg = c;
        logger=_logger;
        email_service= e;
        IConfigurationSection rabbitmq_cfg = cfg.GetSection("RabbitMQ");

        rabbitmq = new()
        {
            hostname = rabbitmq_cfg["HostName"],
            queue = rabbitmq_cfg["QueueName"],
            user = rabbitmq_cfg["UserName"],
            password = rabbitmq_cfg["Password"]
        };
    }

    public static async Task<ContactConsumer> CreateAsync(IConfiguration c, EmailService e, ILogger _logger)
    {

        ContactConsumer consumer = new(c, e,_logger);

        ConnectionFactory factory = new ConnectionFactory()
        {
            HostName = consumer.rabbitmq.hostname!,
            UserName = consumer.rabbitmq.user!,
            Password = consumer.rabbitmq.password!
        };

        bool repeat = true;

        while (repeat)
        {

            try{
                repeat=false;
                consumer.connection = await factory.CreateConnectionAsync();
                consumer.channel = await consumer.connection.CreateChannelAsync();

                await consumer.channel.QueueDeclareAsync(queue: consumer.rabbitmq.queue!,durable:false,exclusive:false,autoDelete:false,arguments:null);
            }
            catch
            {
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
        }

        if (connection != null)
        {
            await connection.DisposeAsync();
        }

    }

   public async Task StartListening()
    {
        if (channel != null)
        {
            AsyncEventingBasicConsumer consumer = new AsyncEventingBasicConsumer(channel);
            consumer.ReceivedAsync += async (sender, input) =>
            {            
                byte[] body = input.Body.ToArray();
                string json = Encoding.UTF8.GetString(body);
                ConsumerMessage? msg = JsonSerializer.Deserialize<ConsumerMessage>(json);

                int delay = 1000;
                const int maxRetries = 3;

                for (int attempt = 0; attempt < maxRetries; attempt++)
                {
                    try
                    {
                        if (msg != null && !string.IsNullOrWhiteSpace(msg.Contact))
                        {
                            await email_service.SendEmail(msg.Contact, msg.Message, msg.Subject, msg.Name);
                        }

                        await channel.BasicAckAsync(input.DeliveryTag, false);
                        logger.LogInformation("Message acked successfully on attempt {Attempt}.", attempt + 1);
                        break;
                    }
                    catch (PermanentDeliveryException ex)
                    {
                        logger.LogCritical(ex, "Permanent delivery failure, message will not be retried. Contact: {Contact}", msg?.Contact);
                        await channel.BasicAckAsync(input.DeliveryTag, false);
                        break;
                    }
                    catch (Exception ex)
                    {
                        logger.LogError(ex, "Delivery failed on attempt {Attempt} of {Max}. Retrying in {Delay}ms.", attempt + 1, maxRetries, delay);
                        if (attempt < maxRetries - 1)
                        {
                            await Task.Delay(delay);
                            delay = Math.Min(delay * 2, 15000);
                        }
                        else
                        {
                            logger.LogError(ex, "Exhausted all {Max} attempts.", maxRetries);
                            await channel.BasicNackAsync(input.DeliveryTag, false, false);
                        }
                    }
                }
            };

            await channel!.BasicConsumeAsync(queue: rabbitmq!.queue!, autoAck: false, consumer: consumer);
        }
    }

}