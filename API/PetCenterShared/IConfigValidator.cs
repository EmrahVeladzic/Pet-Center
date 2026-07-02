using Microsoft.Extensions.Configuration;

namespace PetCenterShared
{

    public interface IConfigValidator
    {
        public string? ValidateEachRun(IConfiguration cfg);

        public string? ValidateFirstRun(IConfiguration cfg);

    }

}