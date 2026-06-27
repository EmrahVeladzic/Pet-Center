using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;
using PetCenterModels.ModelUtils;


namespace PetCenterModels.DataTransferObjects
{
    public class AccountRequestDTO : IBaseRequestDTO
    {       
        [JsonIgnore]
        [ReadOnly(true)]
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        
        [MaxLength(255)]
        public string Contact { get; set; } = string.Empty;
        
        [MinLength(4)]
        [MaxLength(255)]
        public string Password { get; set; } = string.Empty;


        [Required]
        public Access Role {get; set;} = Access.User;    
    

        public bool Validate()
        {            
            Contact=Contact.ToLowerInvariant();
            return ModelValidationUtils.ValidateContact(Contact);
        }
    }
}
