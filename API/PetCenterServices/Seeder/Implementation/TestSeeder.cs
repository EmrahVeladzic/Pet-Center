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
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Formats.Webp;
using PetCenterServices.Services;

namespace PetCenterServices.Seeder
{
    

    public class TestSeeder : ISeeder
    {      

        public PetCenterModels.DBTables.Image CreateRandomImage(Guid album_id,Random rng, short w = 64, short h=64)
        {
            PetCenterModels.DBTables.Image output = new();
            output.AlbumId=album_id;
            output.Width=w;
            output.Height=h;            

            using Image<Rgb24> img = new(w,h);
            img.ProcessPixelRows(accessor =>
            {
                for(int y= 0; y<accessor.Height; y++)
                {
                    Span<Rgb24> row = accessor.GetRowSpan(y);

                    for(int x = 0; x < row.Length; x++)
                    {
                        row[x]=new Rgb24
                        {
                            R=(byte)rng.Next(256),
                            G=(byte)rng.Next(256),
                            B=(byte)rng.Next(256)
                        };
                    }

                }
            });

            using MemoryStream ms = new();

            img.Save(ms, new WebpEncoder()
            {
                Quality = 50
            });

            output.Data = "data:image/webp;base64," + Convert.ToBase64String(ms.ToArray());

            return output;
        }

        public async Task<bool> SeedDatabase(PetCenterDBContext ctx, bool non_static_data)
        {

            List<string> countries = new List<string> { "Scottish","Japanese","Persian","Siamese","German","French","Italian","Russian","Norwegian","Swedish","American","British","Turkish","Egyptian","Indian","Chinese","Thai","Canadian","Australian","Belgian" };
           
            List<string> descriptors = new List<string>
            {
                "fold","grey","spotted","striped","fluffy","short","long","curly","smooth","white",
                "black","brown","golden","tiny","giant","furry","silky","tabby","patch","pied",
                "shaggy","slim","chunky","mottled","dapple","brindle","sable","cream","blue","red",
                "ginger","plush","soft","dense","sleek","prickly","woolly","rust","tan","marble",
                "speckled","blotched","frosted","smoky","coal","sand","ash","pearl","honey","cinnamon"
            };

            List<string> productDescriptors = new List<string> { "Premium","Classic",
            "Soft","Durable","Eco","Organic","Natural",
            "Fresh","Compact","Light","Cozy","Fun","Playful","Safe","Sturdy","Portable",
            "Colorful","Deluxe","Scented","Fresh" };

            using(IDbContextTransaction tx = await ctx.Database.BeginTransactionAsync())
            {
                try
                {
                    Random rng = new();

                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Dogs"});
                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Cats"});
                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Rabbits"});

                    await ctx.SaveChangesAsync();                    
                 
                    await ctx.Categories.AddAsync(new Category{Title="Food",Consumable=true});
                    await ctx.Categories.AddAsync(new Category{Title="Litter",Consumable=true});
                    await ctx.Categories.AddAsync(new Category{Title="Toys",Consumable=false});
                    await ctx.Categories.AddAsync(new Category{Title="Beds",Consumable=false});
                    await ctx.Categories.AddAsync(new Category{Title="Furniture",Consumable=false});

                    await ctx.SaveChangesAsync(); 

                    List<Category> categories = await ctx.Categories.ToListAsync();
                    List<Kind> kinds = await ctx.AnimalKinds.ToListAsync();
                    AnimalScale[] scales = Enum.GetValues<AnimalScale>();

                    foreach(Category cat in categories)
                    {                        
                        
                        foreach(Kind kind in kinds)
                        {

                            int usage_g = rng.Next(50);

                            if (usage_g > 10)
                            {                                
                                await ctx.UsageEstimates.AddAsync(new Usage{KindId=kind.Id,CategoryId=cat.Id,ScaleSpecific=null,AverageDailyAmountGrams=usage_g});

                                await ctx.Items.AddAsync(new Item{CategoryId=cat.Id,KindId=kind.Id,TargetScale=null,MassGrams=(cat.Consumable)?rng.Next(25,1500):null,Title="Generic "+productDescriptors[rng.Next(productDescriptors.Count)].ToLower()+" "+cat.Title.ToLower()+" for "+kind.Title.ToLower()});

                                for(int i = 0; i< scales.Length; i++)
                                {
                                    int usage_g_scale = rng.Next(50);

                                    if(Math.Abs(usage_g - usage_g_scale) > 10)
                                    {
                                        await ctx.UsageEstimates.AddAsync(new Usage{KindId=kind.Id,CategoryId=cat.Id,ScaleSpecific=scales[i],AverageDailyAmountGrams=usage_g_scale});
                                        await ctx.Items.AddAsync(new Item{CategoryId=cat.Id,KindId=kind.Id,TargetScale=scales[i],MassGrams=(cat.Consumable)?rng.Next(25,1500):null,Title=productDescriptors[rng.Next(productDescriptors.Count)]+" "+cat.Title.ToLower()+" for "+scales[i].ToString().ToLower()+" "+kind.Title.ToLower()});
                                    
                                    }
                                }
                            }

                        }
                        
                    }

                    await ctx.SaveChangesAsync();  

                    FormTemplate? template = new FormTemplate{Description="Generic business form"};
                    await ctx.FormTemplates.AddAsync(template);
                    await ctx.SaveChangesAsync();

                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "Business licence ID:",Optional=false});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "How long has this business operated for?",Optional=false});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "Employee count:",Optional=true});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "Are you a non-profit?",Optional=false});

                    await ctx.SaveChangesAsync();
                    template=await ctx.FormTemplates.Include(ft=>ft.Entries).FirstOrDefaultAsync(ft=>ft.Id==template.Id);

                    for(int i = 0; i<50; i++)
                    {
                        bool extended_name = rng.Next(2)==1 && descriptors.Count>1;

                        string first_descriptor = descriptors[rng.Next(descriptors.Count)];
                        descriptors.Remove(first_descriptor);

                        string second_descriptor =(extended_name)? " "+descriptors[rng.Next(descriptors.Count)]:"";

                        Breed breed = new();
                        
                        breed.Title=countries[rng.Next(countries.Count)]+" "+first_descriptor+second_descriptor;

                        breed.KindId=kinds[rng.Next(kinds.Count)].Id;

                        breed.AlbumId=await ImageService.CreateAlbum(null,ctx,1);

                        await ctx.Images.AddAsync(CreateRandomImage(breed.AlbumId,rng));

                        breed.Investment=(float)rng.NextDouble();
                        breed.Territory=(float)rng.NextDouble();
                        breed.Pricing=(float)rng.NextDouble();
                        breed.Longevity=(float)rng.NextDouble();
                        breed.Cohabitation=(float)rng.NextDouble();

                        breed.Scale= scales[rng.Next(scales.Length)];

                        await ctx.AnimalBreeds.AddAsync(breed);

                        await ctx.SaveChangesAsync();
                    }

                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I wish nothing more than to spend as many years as I can with my pet.",LongevityEffect=0.75f,PricingEffect=0.2f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I want a low-maintenance pet.",PricingEffect=-0.25f,InvestmentEffect=-0.65f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I have a large living space.",InvestmentEffect=-0.1f,TerritoryEffect=0.4f,PricingEffect=0.1f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I prefer the baby-era of pet ownership.",LongevityEffect=-0.5f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I have other pets at the moment.",CohabitationEffect=0.8f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I can only afford one pet.",CohabitationEffect=-0.9f,PricingEffect=-0.4f,LongevityEffect=-0.15f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I want a pet that adapts well to small living spaces.",TerritoryEffect=-0.5f,CohabitationEffect=0.2f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I enjoy outdoor activities with my pet.",TerritoryEffect=0.6f,InvestmentEffect=0.1f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I prefer pets that are quiet and unobtrusive.",CohabitationEffect=-0.5f,PricingEffect=-0.2f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I want a low-cost pet that still lives a long life.",PricingEffect=-0.7f,LongevityEffect=0.4f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I like pets that require frequent engagement and play.",InvestmentEffect=0.5f,CohabitationEffect=0.3f,TerritoryEffect=0.2f});

                    await ctx.SaveChangesAsync();
                    
                    Procedure proc = new Procedure{Description="X-Virus vaccination"};
                    await ctx.MedicalProcedures.AddAsync(proc);
                    await ctx.SaveChangesAsync();

                    Guid afflicted_kind_id = kinds[rng.Next(kinds.Count)].Id;
                    List<Breed> afflicted_breeds = await ctx.AnimalBreeds.Where(b=>b.KindId!=afflicted_kind_id).OrderBy(b => Guid.NewGuid()).Take(rng.Next(2,10)).ToListAsync();

                    await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc.Id,KindId=afflicted_kind_id,BreedId=null,SexSpecific=true,Optional=true,IntervalDays=50,ApproximateAge=280});

                    foreach(Breed afflicted_breed in afflicted_breeds)
                    {
                        await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc.Id,KindId=afflicted_breed.KindId,BreedId=afflicted_breed.Id,SexSpecific=(rng.Next(2)==1)?null:false,Optional=false,IntervalDays=null,ApproximateAge=rng.Next(100,400)});
                    }


                    await ctx.SaveChangesAsync();


                    if (non_static_data)
                    {
                        for(int i =1; i<=30; i++)
                        {
                            

                        }
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