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

        public static async Task<int> GetTotalDailyUsageForCategory(PetCenterDBContext ctx, Guid CategoryId, Guid KindId , List<Individual> animals)
        {
            int output = 0;
            animals = animals.Where(a=>a.AnimalBreed!=null && a.AnimalBreed.KindId==KindId).ToList();

            foreach(Individual animal in animals)
            {             
                output +=  await ctx.UsageEstimates
                .Where(u => u.CategoryId == CategoryId && u.KindId == animal.AnimalBreed.KindId &&(u.ScaleSpecific == animal.AnimalBreed.Scale || u.ScaleSpecific == null))
                .OrderByDescending(u => u.ScaleSpecific != null).Select(u => u.AverageDailyAmountGrams).FirstOrDefaultAsync();
            }

            return output;
        }

       
    }
}
