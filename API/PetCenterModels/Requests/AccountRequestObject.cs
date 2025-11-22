using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.Requests
{
    public class AccountRequestObject
    {
        [Required]
        public string? Contact { get; set; }
        
        [Required]
        public string? Password { get; set; }
    }
}
