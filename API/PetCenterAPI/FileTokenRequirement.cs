using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PetCenterAPI.Filters
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class RequireFileTokenAttribute : Attribute, IAsyncActionFilter
    {
        private const string HeaderName = "X-File-Token";

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            HttpContext httpContext = context.HttpContext;

            string? fileToken = httpContext.Request.Headers[HeaderName];

            if (string.IsNullOrWhiteSpace(fileToken))
            {
                context.Result = new ObjectResult("Missing file token.") { StatusCode = 401 };
                return;
            }

            var configuration = PetCenterServices.Utils.Crypto.Configuration;

            var validationParameters = new TokenValidationParameters
            {
                ValidAlgorithms = new[] { SecurityAlgorithms.HmacSha256 },
                ValidateIssuer = true,
                ValidIssuer = configuration["Jwt:Issuer"],
                ValidateAudience = true,
                ValidAudience = configuration["Jwt:Audience"],
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!))
                    
            };

            var handler = new JwtSecurityTokenHandler();

            try
            {
                ClaimsPrincipal filePrincipal = handler.ValidateToken(fileToken, validationParameters, out _);

                if (httpContext.User.Identity is ClaimsIdentity existingIdentity)
                {
                    foreach (Claim claim in filePrincipal.Claims)
                    {
                        existingIdentity.AddClaim(claim);
                    }
                }
                else
                {
                    httpContext.User = filePrincipal;
                }
            }
            catch (SecurityTokenExpiredException)
            {
                context.Result = new ObjectResult("File token expired.") { StatusCode = 401 };
                return;
            }
            catch
            {
                context.Result = new ObjectResult("Invalid file token.") { StatusCode = 401 };
                return;
            }

            await next();
        }
    }
}