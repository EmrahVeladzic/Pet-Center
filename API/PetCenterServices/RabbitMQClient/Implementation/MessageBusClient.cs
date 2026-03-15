using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using PetCenterServices;
using PetCenterShared;
using RabbitMQ.Client;

public class MessageBusClient : IMessageBusClient
{
    private readonly RabbitMQSettings _settings;

    private class RabbitMQSettings {
        public string HostName { get; set; } = "localhost";
        public string QueueName { get; set; } = "PetCenterContactQueue";
        public string UserName { get; set; } = "guest";
        public string Password { get; set; } = "guest";
    }

    public MessageBusClient(IConfiguration config)
    {
       
        IConfigurationSection section = config.GetSection("RabbitMQ");
        _settings = new RabbitMQSettings
        {
            HostName = section["HostName"] ?? "localhost",
            QueueName = section["QueueName"] ?? "PetCenterContactQueue",
            UserName = section["UserName"] ?? "guest",
            Password = section["Password"] ?? "guest"
        };

       
        string? envHost = Environment.GetEnvironmentVariable("RABBITMQ_HOSTNAME");
        if (!string.IsNullOrWhiteSpace(envHost)) _settings.HostName = envHost;

        string? envQueue = Environment.GetEnvironmentVariable("RABBITMQ_QUEUENAME");
        if (!string.IsNullOrWhiteSpace(envQueue)) _settings.QueueName = envQueue;

        string? envUser = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME");
        if (!string.IsNullOrWhiteSpace(envUser)) _settings.UserName = envUser;

        string? envPass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");
        if (!string.IsNullOrWhiteSpace(envPass)) _settings.Password = envPass;
    }

    public async Task SendEmailMessage(ConsumerMessage message)
    {
        ConnectionFactory factory = new ConnectionFactory()
        {
            HostName = _settings.HostName,
            UserName = _settings.UserName,
            Password = _settings.Password
        };     

        bool repeat = true;
        while (repeat)
        {
            try
            {           
                repeat=false;    
                using IConnection connection = await factory.CreateConnectionAsync();
                using IChannel channel = await connection.CreateChannelAsync();

                await channel.QueueDeclareAsync(queue: _settings.QueueName, durable: false, exclusive: false, autoDelete: false);

                string json = JsonSerializer.Serialize(message);
                byte[] body = Encoding.UTF8.GetBytes(json);

                await channel.BasicPublishAsync(exchange: string.Empty, routingKey: _settings.QueueName, body: body);
                        
            }
            catch
            {
                repeat=true;
                await Task.Delay(2000); 
            }
        }

        
    }
}