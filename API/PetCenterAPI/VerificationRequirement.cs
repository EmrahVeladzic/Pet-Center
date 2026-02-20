using Microsoft.AspNetCore.Authorization;

public class VerificationHandler : AuthorizationHandler<VerificationRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        VerificationRequirement requirement)
    {
        HttpContext? httpContext = context.Resource as HttpContext;

        if (httpContext == null)
        {
            context.Fail();
            return Task.CompletedTask;
        }

        Endpoint? endpoint = httpContext?.GetEndpoint();

        if (endpoint?.Metadata.GetMetadata<IAllowAnonymous>() != null)
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }

        else if (endpoint?.Metadata.GetMetadata<AllowUnverifiedAttribute>() != null)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                context.Succeed(requirement);
            }
            return Task.CompletedTask;
        }

        else if (context.User.HasClaim(c => c.Type == "verified" && string.Equals(c.Value, "true", StringComparison.OrdinalIgnoreCase)))
        {
            context.Succeed(requirement);
            return Task.CompletedTask;
        }

        else{
            context.Fail();
        }

        return Task.CompletedTask;
    }
}

public class VerificationRequirement : IAuthorizationRequirement { }
