using Microsoft.AspNetCore.Authorization;

public class VerificationHandler : AuthorizationHandler<VerificationRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        VerificationRequirement requirement)
    {
        HttpContext? httpContext = context.Resource as HttpContext;
        Endpoint? endpoint = httpContext?.GetEndpoint();

        if (endpoint?.Metadata.GetMetadata<IAllowAnonymous>() != null)
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }

        if (endpoint?.Metadata.GetMetadata<AllowUnverifiedAttribute>() != null)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                context.Succeed(requirement);
            }
            return Task.CompletedTask;
        }

        if (context.User.HasClaim(c => c.Type == "verified" && c.Value == "true"))
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }

        return Task.CompletedTask;
    }
}

public class VerificationRequirement : IAuthorizationRequirement { }
