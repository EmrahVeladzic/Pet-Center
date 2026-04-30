using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.ModelUtils
{
    public static class ModelValidationUtils
    {
        public static bool ValidateContact(string? contact)
        {
            if(string.IsNullOrWhiteSpace(contact)){return false;}

            EmailAddressAttribute e = new();
            return e.IsValid(contact);
        }

        public static bool IsMature(Account? acc)
        {
            if(acc==null){return false;}
            return acc.RegistrationDate.AddDays(7) <= DateTime.UtcNow;
        }
    }
}
