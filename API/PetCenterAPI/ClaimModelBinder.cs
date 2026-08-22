using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;

namespace PetCenterAPI
{
    public sealed class InvalidTokenException : Exception
    {
        public InvalidTokenException() : base("Invalid token.") { }
    }

    public sealed class ClaimModelBinder : IModelBinder
    {
        public Task BindModelAsync(ModelBindingContext ctx)
        {
            ArgumentNullException.ThrowIfNull(ctx);

            FromClaimAttribute? attribute = (ctx.ModelMetadata as DefaultModelMetadata)?
                .Attributes.ParameterAttributes?
                .OfType<FromClaimAttribute>()
                .FirstOrDefault();

            if (attribute == null)
            {
                throw new InvalidTokenException();
            }

            string? raw = ctx.HttpContext.User.FindFirst(attribute.ClaimType)?.Value;

            Type target = Nullable.GetUnderlyingType(ctx.ModelType) ?? ctx.ModelType;

            object? value = null;

            if (target == typeof(Guid) && Guid.TryParse(raw, out Guid parsed_guid))
            {
                value = parsed_guid;
            }
            else if (target == typeof(DateTime) && long.TryParse(raw, out long seconds))
            {
                value = DateTimeOffset.FromUnixTimeSeconds(seconds).UtcDateTime;
            }
            else if (target == typeof(string) && !string.IsNullOrWhiteSpace(raw))
            {
                value = raw;
            }

            if (value == null)
            {
                throw new InvalidTokenException();
            }

            ctx.Result = ModelBindingResult.Success(value);

            return Task.CompletedTask;
        }
    }

    public sealed class ClaimModelBinderProvider : IModelBinderProvider
    {
        public IModelBinder? GetBinder(ModelBinderProviderContext ctx)
        {
            ArgumentNullException.ThrowIfNull(ctx);

            bool matches = (ctx.Metadata as DefaultModelMetadata)?
                .Attributes.ParameterAttributes?
                .OfType<FromClaimAttribute>()
                .Any() == true;

            return matches ? new ClaimModelBinder() : null;
        }
    }
}