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
        public static async Task<string> GenerateUsername(PetCenterDBContext ctx)
        {
            string output = "";
            do
            {
               output = $"{Adjectives[Rng.Next(Adjectives.Length)]}{Animals[Rng.Next(Animals.Length)]}{Rng.Next(100000000, 1000000000)}";
            }while(await ctx.Users.AnyAsync(u=>u.UserName==output));
            
            return output;
        }

        public static string GetRole(Access input)
        {
            switch (input)
            {
                case Access.Owner: return "Owner";
                case Access.Admin: return "Admin";                
                case Access.BusinessAccount: return "Employee";
                default: return "User";
            }
        }

     

        public static int GetTotalDailyUsageForCategory(
            List<Usage> estimates,
            Guid categoryId,
            Guid kindId,
            List<Individual> animals)
        {
            List<Individual> relevantAnimals = animals
                .Where(a => a.AnimalBreed != null && a.AnimalBreed.KindId == kindId)
                .ToList();

            List<Usage> relevant = estimates
                .Where(u => u.CategoryId == categoryId && u.KindId == kindId)
                .ToList();

            int output = 0;
            foreach (Individual animal in relevantAnimals)
            {
                AnimalScale scale = animal.AnimalBreed.Scale;
                int value = relevant
                    .Where(e => e.ScaleSpecific == scale || e.ScaleSpecific == null)
                    .OrderByDescending(e => e.ScaleSpecific != null)
                    .Select(e => e.AverageDailyAmountGrams)
                    .FirstOrDefault();
                output += value;
            }
            return output;
        }
       
    }
}
