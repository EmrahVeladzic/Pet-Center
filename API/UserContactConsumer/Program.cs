using Microsoft.Extensions.Configuration;
using UserContactConsumer.Services;
class Program
{
    static async Task Main(string[] args)
    {
        IConfigurationBuilder builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json")
            .AddEnvironmentVariables();

        var configuration = builder.Build();

        EmailService email_service = new(configuration);
        ContactConsumer consumer = await ContactConsumer.CreateAsync(configuration, email_service);
     
        Thread.Sleep(Timeout.Infinite);
    }
}