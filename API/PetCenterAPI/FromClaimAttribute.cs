using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.IdentityModel.JsonWebTokens;
using System.Security.Claims;

namespace PetCenterAPI
{
    [AttributeUsage(AttributeTargets.Parameter, AllowMultiple = false, Inherited = true)]
    public class FromClaimAttribute : Attribute, IBindingSourceMetadata
    {
        public string ClaimType { get; }

        public FromClaimAttribute(string claim_type)
        {
            ClaimType = claim_type;
        }

        public BindingSource? BindingSource => BindingSource.Custom;
    }

    public sealed class UserIdAttribute : FromClaimAttribute
    {
        public UserIdAttribute() : base(ClaimTypes.NameIdentifier) { }
    }

    public sealed class SessionIdAttribute : FromClaimAttribute
    {
        public SessionIdAttribute() : base(JwtRegisteredClaimNames.Jti) { }
    }

    public sealed class SessionExpiryAttribute : FromClaimAttribute
    {
        public SessionExpiryAttribute() : base(JwtRegisteredClaimNames.Exp) { }
    }
}