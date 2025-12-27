using Microsoft.EntityFrameworkCore;
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

        private static readonly string[] Adjectives = { "Blue", "Happy", "Quick", "Silent", "Tiny", "Playful" };
        private static readonly string[] Animals = { "Fox", "Bear", "Otter", "Panda", "Wolf", "Tiger" };

        private static Random Rng = new();
        public static async Task<string> GenerateUsername()
        {
            return $"{Adjectives[Rng.Next(Adjectives.Length)]}{Animals[Rng.Next(Animals.Length)]}{Rng.Next(100, 999)}";
        }

        public static string GetRole(Access input)
        {
            switch (input)
            {
                case Access.Owner: return "Owner";
                case Access.Admin: return "Admin";
                case Access.BusinessManager: return "Manager";
                case Access.BusinessEmployee: return "Employee";
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
