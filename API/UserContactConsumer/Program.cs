using Microsoft.Extensions.Configuration;
using UserContactConsumer.Services;
using Microsoft.Extensions.Logging;

class Program
{
    static async Task Main(string[] args)
    {
   
        IConfigurationBuilder builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json")
            .AddEnvironmentVariables();

        IConfigurationRoot configuration = builder.Build();

        using ILoggerFactory loggerFactory = LoggerFactory.Create(logging =>
        {
            logging
                .AddConsole()
                .SetMinimumLevel(LogLevel.Information); 
        });

        ILogger<Program> logger = loggerFactory.CreateLogger<Program>();

        ConsumerConfigValidator validator = new();

        string? validation = validator.ValidateEachRun(configuration);

        if (validation != null)
        {
            logger.LogCritical(validation);
            return; 
        }

        EmailService email_service = new(configuration, loggerFactory.CreateLogger<EmailService>());
        ContactConsumer consumer = await ContactConsumer.CreateAsync(configuration, email_service, loggerFactory.CreateLogger<ContactConsumer>());

        await consumer.StartListening();

        await Task.Delay(Timeout.Infinite);

    }
}