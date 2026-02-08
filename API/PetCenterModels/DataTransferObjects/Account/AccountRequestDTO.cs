using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.Requests
{
    public class AccountRequestDTO : IBaseRequestDTO
    {
        [JsonIgnore]
        public Guid? Id {get; set;}

        [Required]
        public string Contact { get; set; } = string.Empty;
        
        [Required]
        public string Password { get; set; } = string.Empty;
    

        public bool Validate()
        {
            EmailAddressAttribute e = new();
            return (e.IsValid(Contact)&& !string.IsNullOrWhiteSpace(Password));
        }
    }
}
