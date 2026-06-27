using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PetCenterServices;
using PetCenterShared;
using RabbitMQ.Client;


public class MessageBusClient : IMessageBusClient
{
    private readonly RabbitMQSettings _settings;
    private readonly ILogger logger;
    private IConnection? _connection;

        private class RabbitMQSettings
    {
        public string HostName { get; set; } = string.Empty;
        public string QueueName { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public MessageBusClient(IConfiguration config, ILoggerFactory loggerFactory)
    {
        IConfigurationSection section = config.GetSection("RabbitMQ");
        _settings = new RabbitMQSettings
        {
            HostName = section["HostName"]!,
            QueueName = section["QueueName"]!,
            UserName = section["UserName"]!,
            Password = section["Password"]!
        };
        logger = loggerFactory.CreateLogger(GetType());
    }

    private async Task<IConnection> GetConnectionAsync()
    {
        if (_connection != null) return _connection;
        ConnectionFactory factory = new ConnectionFactory()
        {
            HostName = _settings.HostName,
            UserName = _settings.UserName,
            Password = _settings.Password
        };
        _connection = await factory.CreateConnectionAsync();
        return _connection;
    }

    public async Task SendEmailMessage(ConsumerMessage message)
    {
        int delay = 1000;
        const int maxRetries = 3;

        for (int attempt = 0; attempt < maxRetries; attempt++)
        {
            try
            {
                IConnection connection = await GetConnectionAsync();
                using IChannel channel = await connection.CreateChannelAsync();
                await channel.QueueDeclareAsync(
                    queue: _settings.QueueName,
                    durable: false,
                    exclusive: false,
                    autoDelete: false
                );
                string json = JsonSerializer.Serialize(message);
                byte[] body = Encoding.UTF8.GetBytes(json);
                await channel.BasicPublishAsync(
                    exchange: string.Empty,
                    routingKey: _settings.QueueName,
                    body: body
                );
                return;
            }
            catch (Exception ex)
            {
                _connection = null;
                logger.LogWarning(ex, "Failed to send message. Attempt {Attempt} of {Max}.", attempt + 1, maxRetries);
                if (attempt < maxRetries - 1)
                {
                    await Task.Delay(delay);
                    delay = Math.Min(delay * 2, 15000);
                }
                else
                {
                    logger.LogError(ex, "Exhausted all {Max} attempts.", maxRetries);
                }
            }
        }
    }
}
