using Microsoft.Extensions.Configuration;
using PetCenterShared;

public class ConsumerConfigValidator : IConfigValidator
{
    public string? ValidateFirstRun(IConfiguration cfg)
    {
        return null;
    }

    public string? ValidateEachRun(IConfiguration cfg)
    {
        if (string.IsNullOrEmpty(cfg["RabbitMQ:HostName"]))
        {
            return "RabbitMQ:HostName is missing";
        }

        if (string.IsNullOrEmpty(cfg["RabbitMQ:QueueName"]))
        {
            return "RabbitMQ:QueueName is missing";
        }

        if (string.IsNullOrEmpty(cfg["RabbitMQ:UserName"]))
        {
            return "RabbitMQ:UserName is missing";
        }

        if (string.IsNullOrEmpty(cfg["RabbitMQ:Password"]))
        {
            return "RabbitMQ:Password is missing";
        }

        if (string.IsNullOrEmpty(cfg["Email:SmtpServer"]))
        {
            return "Email:SmtpServer is missing";
        }

        if (!int.TryParse(cfg["Email:SmtpPort"], out _))
        {
            return "Email:SmtpPort is missing or not a valid integer";
        }

        if (string.IsNullOrEmpty(cfg["Email:ApplicationEmail"]))
        {
            return "Email:ApplicationEmail is missing";
        }

        return null;
    }
}