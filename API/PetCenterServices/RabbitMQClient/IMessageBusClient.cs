using Microsoft.Extensions.Configuration;
using PetCenterShared;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;

namespace PetCenterServices
{
    public interface IMessageBusClient
    {
        Task SendEmailMessage(ConsumerMessage message);
    }


}