using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace PetCenterAPI
{
    public sealed class ClaimParameterOperationFilter : IOperationFilter
    {
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            if (operation.Parameters == null)
            {
                return;
            }

            foreach (var described in context.ApiDescription.ParameterDescriptions)
            {
                if (described.ParameterDescriptor is not ControllerParameterDescriptor descriptor)
                {
                    continue;
                }

                if (descriptor.ParameterInfo.GetCustomAttributes(typeof(FromClaimAttribute), true).Length == 0)
                {
                    continue;
                }

                OpenApiParameter? existing = operation.Parameters
                    .FirstOrDefault(p => p.Name == described.Name);

                if (existing != null)
                {
                    operation.Parameters.Remove(existing);
                }
            }
        }
    }
}