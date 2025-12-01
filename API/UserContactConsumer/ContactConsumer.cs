using Microsoft.Extensions.Configuration;
using MimeKit;
using MailKit.Net.Smtp;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using UserContactConsumer.Services;

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
    private IChannel? channel;
    private readonly EmailService email_service;
    private readonly RabbitMQCfg rabbitmq;
    private IConnection? connection;

    public ContactConsumer(IConfiguration c, EmailService e)
    {
        cfg = c;
        email_service= e;
        IConfigurationSection rabbitmq_cfg = cfg.GetSection("RabbitMQ");

        rabbitmq = new()
        {
            hostname = rabbitmq_cfg["HostName"],
            queue = rabbitmq_cfg["QueueName"],
            user = rabbitmq_cfg["UserName"],
            password = rabbitmq_cfg["Password"]

        };

        string? host = Environment.GetEnvironmentVariable("RABBITMQ_HOSTNAME");

        if (!string.IsNullOrWhiteSpace(host))
        {
            rabbitmq.hostname = host;
        }

        string? queue = Environment.GetEnvironmentVariable("RABBITMQ_QUEUENAME");

        if (!string.IsNullOrWhiteSpace(queue))
        {
            rabbitmq.queue = queue;
        }


        string? user = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME");

        if (!string.IsNullOrWhiteSpace(user))
        {
            rabbitmq.user = user;
        }

        string? pwd = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");

        if (!string.IsNullOrWhiteSpace(pwd))
        {
            rabbitmq.password = pwd;
        }

      
    }

    public static async Task<ContactConsumer> CreateAsync(IConfiguration c, EmailService e)
    {
        ContactConsumer consumer = new(c, e);

        ConnectionFactory factory = new ConnectionFactory()
        {
            HostName = consumer.rabbitmq.hostname!,
            UserName = consumer.rabbitmq.user!,
            Password = consumer.rabbitmq.password!
        };

        consumer.connection = await factory.CreateConnectionAsync();
        consumer.channel = await consumer.connection.CreateChannelAsync();

        await consumer.channel.QueueDeclareAsync(queue: consumer.rabbitmq.queue!,durable:false,exclusive:false,autoDelete:false,arguments:null);
        
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

    public void StartListening()
    {
        AsyncEventingBasicConsumer c = new(channel!);

    }

   

}