using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Linq.Expressions;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Seeder
{
    

    public class Seeder : ISeeder
    {      

        const int categories = 5;
        const int products = 5;

        public async Task<bool> SeedDatabase(PetCenterDBContext ctx, bool non_static_data)
        {
            using(IDbContextTransaction tx = await ctx.Database.BeginTransactionAsync())
            {
                try
                {
                    Random rng = new();

                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Dogs"});
                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Cats"});

                    await ctx.SaveChangesAsync();

                    
                    for(int i = 1; i <= categories; i++)
                    {
                        bool is_consumable = (i&1)==1;
                        await ctx.Categories.AddAsync(new Category{Title=$"Category-{i} - {((is_consumable)? "C":"NC")}",});
                    }

                    await ctx.SaveChangesAsync();

                    List<Guid> category_ids = await ctx.Categories.Select(x=>x.Id).ToListAsync();
                    List<Guid> kind_ids = await ctx.AnimalKinds.Select(x=>x.Id).ToListAsync();


                    int prod = 1;
                    AnimalScale[] animal_scales = Enum.GetValues<AnimalScale>();
                    for(int i = 0; i<kind_ids.Count; i++)
                    {                        
                        for (int j= 0; j< category_ids.Count; j++)
                        {                            
                            await ctx.Items.AddAsync(new Item{Title=$"Product-{prod}",CategoryId=category_ids[rng.Next(category_ids.Count)],KindId=kind_ids[rng.Next(kind_ids.Count)],TargetScale=animal_scales[rng.Next(animal_scales.Length)],MassGrams=rng.Next(100,1000)});
                            prod++;
                        }

                    }

                    
                    


                    if (non_static_data)
                    {
                        
                    }
                    await tx.CommitAsync();
                    return true;
                }
                catch
                {
                    await tx.RollbackAsync();
                    return false;
                }
            }

        }

    }


}