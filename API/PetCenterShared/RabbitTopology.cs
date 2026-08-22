using RabbitMQ.Client;

namespace PetCenterShared
{
  
    public static class RabbitTopology
    {
        public const string DeadLetterExchange = "petcenter.contact.dlx";

        public static string DeadLetterQueueName(string queueName) => $"{queueName}.dlq";


        public static async Task DeclareAsync(IChannel channel, string queueName,
            CancellationToken ct = default)
        {
            ArgumentNullException.ThrowIfNull(channel);
            ArgumentException.ThrowIfNullOrWhiteSpace(queueName);

            string dlq = DeadLetterQueueName(queueName);

            await channel.ExchangeDeclareAsync(
                exchange: DeadLetterExchange,
                type: ExchangeType.Fanout,
                durable: true,
                autoDelete: false,
                arguments: null,
                cancellationToken: ct);

            await channel.QueueDeclareAsync(
                queue: dlq,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null,
                cancellationToken: ct);

            await channel.QueueBindAsync(
                queue: dlq,
                exchange: DeadLetterExchange,
                routingKey: string.Empty,
                arguments: null,
                cancellationToken: ct);

            await channel.QueueDeclareAsync(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: new Dictionary<string, object?>
                {
                    ["x-dead-letter-exchange"] = DeadLetterExchange
                },
                cancellationToken: ct);
        }
    }
}