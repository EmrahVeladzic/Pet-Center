using Microsoft.Extensions.Configuration;
using PetCenterShared;

namespace PetCenterAPI
{
    public class APIConfigValidator : IConfigValidator
    {
        public string? ValidateEachRun(IConfiguration cfg)
        {
            if (string.IsNullOrEmpty(cfg.GetConnectionString("DefaultConnection")))
            {
                return "ConnectionStrings:DefaultConnection is missing";
            }

            if (string.IsNullOrEmpty(cfg["Jwt:Key"]))
            {
                return "Jwt:Key is missing";
            }

            if (string.IsNullOrEmpty(cfg["Jwt:Issuer"]))
            {
                return "Jwt:Issuer is missing";
            }

            if (string.IsNullOrEmpty(cfg["Jwt:Audience"]))
            {
                return "Jwt:Audience is missing";
            }

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

            if (string.IsNullOrEmpty(cfg["Cors:AllowedOrigins"]) && string.IsNullOrEmpty(cfg["Cors__AllowedOrigins"]))
            {
                return "Cors:AllowedOrigins is missing";
            }

            return null;
        }

        public string? ValidateFirstRun(IConfiguration cfg)
        {
            if (string.IsNullOrEmpty(cfg["InstanceOwner:Contact"]))
            {
                return "InstanceOwner:Contact is missing";
            }

            if (string.IsNullOrEmpty(cfg["InstanceOwner:Password"]))
            {
                return "InstanceOwner:Password is missing";
            }

            if (!int.TryParse(cfg["Seeder:Seed"], out _))
            {
                return "Seeder:Seed is missing or not a valid integer";
            }

            if (!bool.TryParse(cfg["Seeder:Static"], out _))
            {
                return "Seeder:Static is missing or not a valid boolean";
            }

            return null;
        }
    }
}