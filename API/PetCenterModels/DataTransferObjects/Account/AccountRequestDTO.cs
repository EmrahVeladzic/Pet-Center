using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.DataTransferObjects
{
    public class AccountRequestDTO : IBaseRequestDTO
    {       
        public Guid? Id {get; set;}

        [Required]
        public string Contact { get; set; } = string.Empty;
        
        [Required]
        public string Password { get; set; } = string.Empty;

        public bool Business {get; set;} = false;    
    

        public bool Validate()
        {
            EmailAddressAttribute e = new();
            return (e.IsValid(Contact)&& !string.IsNullOrWhiteSpace(Password));
        }
    }
}
