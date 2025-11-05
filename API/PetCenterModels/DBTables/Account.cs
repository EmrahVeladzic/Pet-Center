using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Account : BaseTableEntity
    {
        
        [EmailAddress]
        public string? Email {  get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [JsonIgnore]
        [Required]
        public string? PasswordHash { get; set; }

    }
}
