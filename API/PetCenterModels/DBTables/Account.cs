using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Account
    {
        [Key]
        public int Id { get; set; }
        
        [EmailAddress]
        public string? Email {  get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [Required]
        public string? PasswordHash { get; set; }



    }
}
