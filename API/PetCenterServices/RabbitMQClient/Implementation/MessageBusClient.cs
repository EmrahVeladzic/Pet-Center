using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PetCenterServices;
using PetCenterShared;
using RabbitMQ.Client;

public class MessageBusClient : IMessageBusClient, IAsyncDisposable
{
    private readonly RabbitMQSettings _settings;
    private readonly ILogger logger;
    private readonly SemaphoreSlim _connectionLock = new(1, 1);

    private IConnection? _connection;
    private bool _topologyDeclared;

    private sealed class RabbitMQSettings
    {
        public string HostName { get; init; } = string.Empty;
        public string QueueName { get; init; } = string.Empty;
        public string UserName { get; init; } = string.Empty;
        public string Password { get; init; } = string.Empty;

        public void Validate()
        {
            List<string> missing = [];
            if (string.IsNullOrWhiteSpace(HostName)) missing.Add("RabbitMQ:HostName");
            if (string.IsNullOrWhiteSpace(QueueName)) missing.Add("RabbitMQ:QueueName");
            if (string.IsNullOrWhiteSpace(UserName)) missing.Add("RabbitMQ:UserName");
            if (string.IsNullOrWhiteSpace(Password)) missing.Add("RabbitMQ:Password");

            if (missing.Count > 0)
            {
                throw new InvalidOperationException(
                    $"Missing required configuration: {string.Join(", ", missing)}.");
            }
        }
    }

    public MessageBusClient(IConfiguration config, ILoggerFactory loggerFactory)
    {
        IConfigurationSection section = config.GetSection("RabbitMQ");

        _settings = new RabbitMQSettings
        {
            HostName = section["HostName"] ?? string.Empty,
            QueueName = section["QueueName"] ?? string.Empty,
            UserName = section["UserName"] ?? string.Empty,
            Password = section["Password"] ?? string.Empty
        };

        _settings.Validate();

        logger = loggerFactory.CreateLogger(GetType());
    }

    private async Task<IConnection> GetConnectionAsync(CancellationToken ct)
    {
        IConnection? existing = _connection;
        if (existing is { IsOpen: true })
        {
            return existing;
        }


        await _connectionLock.WaitAsync(ct);
        try
        {
            if (_connection is { IsOpen: true })
            {
                return _connection;
            }

            if (_connection is not null)
            {
                try { await _connection.DisposeAsync(); } catch {}
                _connection = null;
                _topologyDeclared = false;
            }

            ConnectionFactory factory = new()
            {
                HostName = _settings.HostName,
                UserName = _settings.UserName,
                Password = _settings.Password,
                AutomaticRecoveryEnabled = true,
                TopologyRecoveryEnabled = true
            };

            _connection = await factory.CreateConnectionAsync(ct);
            return _connection;
        }
        finally
        {
            _connectionLock.Release();
        }
    }

    public async Task SendEmailMessage(ConsumerMessage message)
    {
        ArgumentNullException.ThrowIfNull(message);

        byte[] body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(message));

        int delay = 1000;
        const int maxRetries = 3;
        Exception? last = null;

        for (int attempt = 0; attempt < maxRetries; attempt++)
        {
            try
            {
                IConnection connection = await GetConnectionAsync(CancellationToken.None);
                await using IChannel channel = await connection.CreateChannelAsync();

                if (!_topologyDeclared)
                {
                    await RabbitTopology.DeclareAsync(channel, _settings.QueueName);
                    _topologyDeclared = true;
                }

                BasicProperties props = new()
                {
                    Persistent = true,
                    ContentType = "application/json"
                };

                await channel.BasicPublishAsync(
                    exchange: string.Empty,
                    routingKey: _settings.QueueName,
                    mandatory: false,
                    basicProperties: props,
                    body: body);

                return;
            }
            catch (Exception ex)
            {
                last = ex;
                _topologyDeclared = false;
                _connection = null;

                logger.LogWarning(ex, "Failed to send message. Attempt {Attempt} of {Max}.",
                    attempt + 1, maxRetries);

                if (attempt < maxRetries - 1)
                {
                    await Task.Delay(delay);
                    delay = Math.Min(delay * 2, 15000);
                }
            }
        }

        logger.LogError(last, "Exhausted all {Max} attempts; message was not published.", maxRetries);

        throw new InvalidOperationException(
            "Could not publish message to the bus after retries.", last);
    }

    public async ValueTask DisposeAsync()
    {
        if (_connection is not null)
        {
            try { await _connection.DisposeAsync(); } catch { }
            _connection = null;
        }

        _connectionLock.Dispose();
        GC.SuppressFinalize(this);
    }
}