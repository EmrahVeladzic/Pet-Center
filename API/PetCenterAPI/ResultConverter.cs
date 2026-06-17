using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using PetCenterServices.Utils;

namespace PetCenterAPI.Controllers
{   

    public static class ResultConverter
    {
        public static IActionResult Convert<T>(ServiceOutput<T> output){
            if (output.Code == HttpCode.NoContent)
            {
                return new Microsoft.AspNetCore.Mvc.NoContentResult(); 
            }
        
            if (!ServiceOutput<T>.IsSuccess(output))
            {
                return new ObjectResult(new { error = output.ErrorMessage }) 
                { 
                    StatusCode = (int)output.Code 
                };
            }

            if (output.Body is byte[] bytes)
            {
                
                return new FileContentResult(bytes, "application/octet-stream");

            }

            
            bool isPrimitive = output.Body is string or ValueType;
            if (isPrimitive)
            {
                return new ObjectResult(new { value = output.Body })
                {
                    StatusCode = (int)output.Code,
                    ContentTypes = { "application/json" }
                };
            }

            return new ObjectResult(output.Body)
            {
                StatusCode = (int)output.Code,
                ContentTypes = { "application/json" }
            };
        }

        public static async Task WriteAsync(HttpContext context, ServiceOutput<object> output)
        {
            context.Response.StatusCode = (int)output.Code;
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsync(JsonSerializer.Serialize(
                new { error = output.ErrorMessage }));
        }


    }
}