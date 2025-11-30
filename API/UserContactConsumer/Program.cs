using Microsoft.Extensions.Configuration;
class Program
{
    static void Main(string[] args)
    {
        IConfigurationBuilder builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json")
            .AddEnvironmentVariables();

        var configuration = builder.Build();

     
        Thread.Sleep(Timeout.Infinite);
    }
}