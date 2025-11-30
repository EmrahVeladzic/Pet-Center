using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Utils
{
    public static class UserUtils
    {
        public static string GenerateUsername(PetCenterDBContext ctx)
        {
            string username;

            do{
                username = "User_" + Guid.NewGuid().ToString("N").Substring(0, 8);
            }
            while (ctx.Users.Any(u => u.UserName == username));

            return username;
        }

        public static string GetRole(Access input)
        {
            switch (input)
            {
                case Access.Owner: return "Owner";
                case Access.Admin: return "Admin";
                default: return "User";
            }
        }

        public static bool ValidateContact(string contact)
        {
            EmailAddressAttribute e = new();
            return e.IsValid(contact);
        }

    }
}
