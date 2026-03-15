
using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

namespace PetCenterServices.Utils
{
    public enum HttpCode : int
    {
    
        OK = 200,
        Created = 201,
        NoContent = 204,

    
        BadRequest = 400,
        Unauthorized = 401,
        Forbidden = 403,
        NotFound = 404,
        Conflict = 409,
        TooManyRequests = 429,

        InternalError = 500,
        NotImplemented = 501

    }


    public class ServiceOutput<T>
    {
        public HttpCode Code {get; set;}

        public string? ErrorMessage {get; set;}

        public T? Body {get; set;}

        public static ServiceOutput<T> Success(T? body, HttpCode code = HttpCode.OK) => new(code, body, null);
        public static ServiceOutput<T> Error(HttpCode code, string message) => new(code, default, message);

        public static ServiceOutput<T> FromException(Exception ex)
        {
            return (ex) switch    
            {
                DbUpdateConcurrencyException => ServiceOutput<T>.Error(HttpCode.Conflict, "The resource was modified by another process."),
                ValidationException => ServiceOutput<T>.Error(HttpCode.BadRequest, "The provided data did not pass validation."),
                KeyNotFoundException => ServiceOutput<T>.Error(HttpCode.NotFound, "The selected resource does not exist."),
                UnauthorizedAccessException => ServiceOutput<T>.Error(HttpCode.Forbidden, "You lack the permission to perform this action."),
                DbUpdateException => ServiceOutput<T>.Error(HttpCode.BadRequest, "A database update error occurred."),
                _ => ServiceOutput<T>.Error(HttpCode.InternalError, "Internal server error.")
            };      
        }

        public static bool IsSuccess(ServiceOutput<T> input){return (int)input.Code<400;}

        public ServiceOutput(HttpCode code, T? body = default, string? errorMessage = null)
{
            Code = code;
            Body = body;
            ErrorMessage = errorMessage;
}
        }   

        

}