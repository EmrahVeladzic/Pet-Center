using Microsoft.Extensions.Configuration;
using MimeKit;
using MailKit.Net.Smtp;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using UserContactConsumer.Services;
using PetCenterShared;
using System.Text.Json;
using System.ComponentModel.DataAnnotations;

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

                if(sender is IChannel chn){

                    byte[] body = input.Body.ToArray();
                    string json = Encoding.UTF8.GetString(body);
                    ConsumerMessage? msg = JsonSerializer.Deserialize<ConsumerMessage>(json);

                    

                    if (msg != null && !string.IsNullOrWhiteSpace(msg.Contact))
                    {

                        EmailAddressAttribute attribute = new EmailAddressAttribute();
                        if (attribute.IsValid(msg.Contact)){

                            await email_service.SendEmail(msg.Contact, msg.Message, msg.Subject, msg.Name);

                        }
                

                    }  

                    await chn.BasicAckAsync(input.DeliveryTag,false);    

                }      

            };

            await channel!.BasicConsumeAsync(queue:rabbitmq!.queue!,autoAck:false,consumer:consumer);

        
        }
         

    }


}