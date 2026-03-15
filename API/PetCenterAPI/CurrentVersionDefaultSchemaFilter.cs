using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

public class CurrentVersionSchemaFilter : ISchemaFilter
{
    public void Apply(OpenApiSchema schema, SchemaFilterContext context)
    {
        if (context.MemberInfo?.Name == "CurrentVersion" && schema.Type == "string")
        {
            
            schema.Default = new OpenApiString("");
        }
    }
}