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
using PetCenterServices.Utils;
using Microsoft.Extensions.Logging;
using PetCenterModels.ModelUtils;

namespace PetCenterServices.Seeder
{
    public class BLOBRef
    {
        public string Hash {get; set;} = string.Empty;

        public short W {get; set; } = 0;

        public short H {get; set;} = 0;

    }

    public class TestSeeder : ISeeder
    {      
        public List<string> WordList { get; set; } = new List<string>
        {
            " Lorem", " ipsum", " dolor", " \n", " sit", " amet,", " consectetur", " adipiscing", " elit.", 
            " \n\n", " Sed", " do", " eiusmod", " tempor", " incididunt", " ut", " labore", " \n\n\n", 
            " et", " dolore", " magna", " aliqua.", " Ut", " enim", " ad", " minim", " \n", " veniam,", 
            " quis", " nostrud", " exercitation", " ullamco", " laboris", " nisi", " ut", " \n\n", " aliquip", 
            " ex", " ea", " commodo", " consequat.", " Duis", " aute", " irure", " dolor", " \n", " in",                
            " \n\n", " laudantium.", " Totam", " rem", " aperiam,", " eaque", " ipsa", " quae", " ab", 
            " \n", " illo", " inventore", " veritatis", " et", " quasi", " architecto", " beatae", " vitae", 
            " \n\n", " dicta", " sunt", " explicabo.", " Nemo", " enim", " ipsam", " voluptatem", " quia", 
            " \n", " voluptas", " sit", " aspernatur", " aut", " odit", " aut", " fugit,", " sed", 
            " \n", " quia", " consequuntur", " magni", " dolores.", " Neque", " porro", " quisquam", " est,", 
            " \n", " qui", " dolorem", " ipsum", " quia", " dolor", " sit", " amet,", " consectetur,", 
            " \n\n", " adipisci", " velit,", " sed", " quia", " non", " numquam.", " Eius", " modi", 
            " \n", " tempora", " incididunt", " ut", " labore", " et", " dolore", " magnam", " aliquam", 
            " \n\n", " quaerat", " voluptatem.", " Ut", " enim", " ad", " minima", " veniam.", " Quis", 
            " \n", " autem", " vel", " eum", " iure", " reprehenderit", " qui", " in", " ea", 
            " \n\n", " voluptate", " velit", " esse", " quam", " nihil", " molestiae", " consequatur.", " Vel", 
            " \n", " illum", " qui", " dolorem", " eum", " fugiat", " quo", " voluptas", " nulla", 
            " \n\n", " pariatur?", " At", " vero", " eos", " et", " accusamus", " et", " iusto", 
            " \n", " odio", " dignissimos.", " Ducimus", " qui", " blanditium", " praesentium", " voluptatum", " deleniti", 
            " \n\n", " atque", " corrupti", " quos", " dolores", " et", " quas", " molestias", " excepturi.", 
            " \n", " Sint", " occaecati", " cupiditate", " non", " provident,", " similique", " sunt", " in", 
            " \n", " culpa", " qui", " officia", " deserunt", " mollitia", " animi,", " id", " est", 
            " \n", " laborum.", " Et", " harum", " quidem", " rerum", " facilis", " est", " et", 
            " \n\n", " expedita", " distinctio.", " Nam", " libero", " tempore,", " cum", " soluta", " nobis", 
            " \n", " est", " eligendi", " optio.", " Cumque", " nihil", " impedit", " quo", " minus", 
            " \n\n", " id", " quod", " maxime", " placeat", " facere", " possimus,", " omnis", " voluptas", 
            " \n", " assumenda", " est.", " Omnis", " dolor", " repellendus.", " Temporibus", " autem", " quibusdam", 
            " \n\n", " et", " aut", " officiis", " debitis", " aut", " rerum", " necessitatibus", " saepe", 
            " \n", " mollitia", " animi,", " id", " est", " laborum", " et", " dolorum", " fuga.", 
            " \n", " Et", " harum", " quidem", " rerum", " facilis", " est", " et", " expedita", 
            " \n", " distinctio.", " Nam", " libero", " tempore,", " cum", " soluta", " nobis", " est", 
            " \n\n", " eligendi", " optio", " cumque", " nihil", " impedit", " quo", " minus", " id", 
            " \n", " quod", " maxime", " placeat.", " Facere", " possimus,", " omnis", " voluptas", " assumenda", 
            " \n\n", " est,", " omnis", " dolor", " repellendus.", " Temporibus", " autem", " quibusdam", " et", 
            " \n", " aut", " officiis.", " Debitis", " aut", " rerum", " necessitatibus", " saepe", " eveniet", 
            " \n\n", " ut", " et", " voluptates", " repudiandae", " sint", " et", " molestiae", " non", 
            " \n", " recusandae."
        };

        public List<BLOBRef> BLOBs {get; set;} = new();

        public string GenerateLoremIpsum(int len, Random rng)
        {
            string output = "Lorem";

            while (output.Length < len)
            {
                int r = rng.Next(len/10);

                if(r==0){break;}

                r= rng.Next(WordList.Count);

                if(output.Length+WordList[r].Length<len){output+=WordList[r];}else{break;}


            }

            return output;
        }

        public async Task<PetCenterModels.DBTables.Image> CreateRandomImage(PetCenterDBContext ctx,  Guid album_id,Random rng, short w = 32, short h=32)
        {
            PetCenterModels.DBTables.Image output = new();
            output.AlbumId=album_id;

            short Width =(short) rng.Next(w/2,w);
            short Height = (short) rng.Next(h/2,h);

            string hash = "";

            if(BLOBs.Count==0 || rng.Next(3)==0){


                int MinR = rng.Next(200);
                int MinG = rng.Next(200);
                int MinB = rng.Next(200);       

                using Image<Rgb24> img = new(Width,Height);
                img.ProcessPixelRows(accessor =>
                {
                    for(int y= 0; y<accessor.Height; y++)
                    {
                        Span<Rgb24> row = accessor.GetRowSpan(y);

                        for(int x = 0; x < row.Length; x++)
                        {
                            row[x]=new Rgb24
                            {
                                R=(byte)rng.Next(MinR,256),
                                G=(byte)rng.Next(MinG,256),
                                B=(byte)rng.Next(MinB,256)
                            };
                        }

                    }
                });

                using MemoryStream ms = new();

                img.Save(ms, new WebpEncoder()
                {
                    Quality = 50
                });

                ImageBLOB blob = new();
                blob.Data=ms.ToArray();
                blob.Id=BLOBHandler.CreateHash(blob.Data);

                await ctx.ImageBLOBs.AddAsync(blob);
                await ctx.SaveChangesAsync();

                hash = blob.Id;

                BLOBs.Add(new BLOBRef{W=Width,H=Height,Hash=hash});
            }
            else
            {
                BLOBRef reference = BLOBs[rng.Next(BLOBs.Count)];

                Width = reference.W;
                Height= reference.H;
                hash=reference.Hash;
            }
        

            output.Width=Width;
            output.Height=Height;     

            output.BLOBId=hash;

            return output;
        }

        public async Task<bool> SeedDatabase(PetCenterDBContext ctx, bool non_static_data,int? seed, ILogger? logger)
        {

            List<string> countries = new List<string> { "Scottish","Japanese","Siamese","German","French","Italian","Russian","Norwegian","Swedish","American","British","Turkish","Egyptian","Chinese","Thai","Canadian","Australian","Belgian" };
           
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

           
            
            
            await using(IDbContextTransaction tx = await ctx.Database.BeginTransactionAsync())
            {
                try
                {
                    Random rng = new();

                    if (seed != null)
                    {
                        rng=new Random((int)seed);
                    }

                    Kind usage_kind = new Kind {Title="Hamsters"};

                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Dogs"});
                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Cats"});
                    await ctx.AnimalKinds.AddAsync(new Kind{Title="Rabbits"});
                   

                    await ctx.SaveChangesAsync();                    
                 
                    await ctx.Categories.AddAsync(new Category{Title="Food",Consumable=true});
                    await ctx.Categories.AddAsync(new Category{Title="Litter",Consumable=true});
                    await ctx.Categories.AddAsync(new Category{Title="Toys",Consumable=false});
                    await ctx.Categories.AddAsync(new Category{Title="Beds",Consumable=false});
                    await ctx.Categories.AddAsync(new Category{Title="Bowls",Consumable=false});

                    await ctx.SaveChangesAsync(); 

                    List<Category> categories = await ctx.Categories.ToListAsync();
                    List<Kind> kinds = await ctx.AnimalKinds.ToListAsync();
                    AnimalScale[] scales = Enum.GetValues<AnimalScale>();

                    await ctx.AnimalKinds.AddAsync(usage_kind);

                    foreach(Category cat in categories)
                    {                        
                        
                        foreach(Kind kind in kinds)
                        {

                            int usage_g = rng.Next(50);

                            if (usage_g > 10)
                            {                     
                                if(cat.Consumable){

                                    await ctx.UsageEstimates.AddAsync(new Usage{KindId=kind.Id,CategoryId=cat.Id,ScaleSpecific=null,AverageDailyAmountGrams=usage_g});

                                }

                                await ctx.Items.AddAsync(new Item{CategoryId=cat.Id,KindId=kind.Id,TargetScale=null,MassGrams=(cat.Consumable)?rng.Next(25,1500):null,Title="Generic "+productDescriptors[rng.Next(productDescriptors.Count)].ToLower()+" "+cat.Title.ToLower()+" for "+kind.Title.ToLower()});

                                for(int i = 0; i< scales.Length; i++)
                                {
                                    int usage_g_scale = rng.Next(50);

                                    if(Math.Abs(usage_g - usage_g_scale) > 10)
                                    {
                                        if (cat.Consumable)
                                        {
                                            
                                            await ctx.UsageEstimates.AddAsync(new Usage{KindId=kind.Id,CategoryId=cat.Id,ScaleSpecific=scales[i],AverageDailyAmountGrams=usage_g_scale});
                                            
                                        }
                                        
                                        await ctx.Items.AddAsync(new Item{CategoryId=cat.Id,KindId=kind.Id,TargetScale=scales[i],MassGrams=(cat.Consumable)?rng.Next(25,1500):null,Title=productDescriptors[rng.Next(productDescriptors.Count)]+" "+cat.Title.ToLower()+" for "+scales[i].ToString().ToLower()+" "+kind.Title.ToLower()});
                                    
                                    }
                                }
                            }

                        }
                        
                    }

                   


                    await ctx.SaveChangesAsync();  

                    FormTemplate? template = new FormTemplate{Description="Generic business form"};
                    FormTemplate? template_two = new FormTemplate{Description="Independent seller form"};
                   
                    await ctx.FormTemplates.AddAsync(template);
                    await ctx.FormTemplates.AddAsync(template_two);
                    await ctx.SaveChangesAsync();

                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "Business licence ID:",Optional=false});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "How long has this business operated for?",Optional=false});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "Employee count:",Optional=true});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template.Id,Description = "Are you a non-profit?",Optional=false});


                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template_two.Id,Description = "Business licence ID:",Optional=false});
                    await ctx.FormTemplateFields.AddAsync(new FormTemplateField{FormTemplateId=template_two.Id,Description = "Personal ID:",Optional=false});

                    await ctx.SaveChangesAsync();
                    template=await ctx.FormTemplates.Include(ft=>ft.Fields).FirstOrDefaultAsync(ft=>ft.Id==template.Id);


                    Guid l_ham_album = await BreedService.CreateAlbum(null,ctx,1);
                    Guid b_ham_album = await BreedService.CreateAlbum(null,ctx,1);

                    await ctx.Images.AddAsync(await CreateRandomImage(ctx,l_ham_album,rng));
                    await ctx.Images.AddAsync(await CreateRandomImage(ctx,b_ham_album,rng));

                    await ctx.SaveChangesAsync();

                    Breed bigHamster = new Breed{AlbumId=b_ham_album, Scale= AnimalScale.Large, KindId=usage_kind.Id,Title="European Furball",Investment=rng.NextSingle(),Territory=rng.NextSingle(),Pricing=rng.NextSingle(),Longevity=0.0f,Cohabitation=rng.NextSingle()};
                    Breed littleHamster = new Breed{AlbumId=l_ham_album, Scale=AnimalScale.Small, KindId=usage_kind.Id,Title="Continental Furball",Investment=rng.NextSingle(),Territory=rng.NextSingle(),Pricing=rng.NextSingle(),Longevity=0.0f,Cohabitation=rng.NextSingle()};



                    await ctx.AnimalBreeds.AddAsync(bigHamster);
                    await ctx.AnimalBreeds.AddAsync(littleHamster);

                    Guid usageCategory = categories.First(c=>c.Consumable==true).Id;

                    Item hamsterItem = new Item{Title="Hamster product", MassGrams = 100, CategoryId= usageCategory, KindId = usage_kind.Id};

                    await ctx.Items.AddAsync(hamsterItem);

                    await ctx.UsageEstimates.AddAsync(new Usage{KindId=usage_kind.Id,ScaleSpecific = AnimalScale.Small, CategoryId=usageCategory,AverageDailyAmountGrams=20});
                    await ctx.UsageEstimates.AddAsync(new Usage{KindId=usage_kind.Id,ScaleSpecific = AnimalScale.Large, CategoryId=usageCategory,AverageDailyAmountGrams=30});

                    for(int i = 0; i<50; i++)
                    {
                        bool extended_name = rng.Next(2)==1 && descriptors.Count>1;

                        string first_descriptor = descriptors[rng.Next(descriptors.Count)];
                        descriptors.Remove(first_descriptor);

                        string second_descriptor =(extended_name)? " "+descriptors[rng.Next(descriptors.Count)]:"";

                        Breed breed = new();
                        
                        breed.Title=countries[rng.Next(countries.Count)]+" "+first_descriptor+second_descriptor;

                        breed.KindId=kinds[rng.Next(kinds.Count)].Id;

                        breed.AlbumId=await BreedService.CreateAlbum(null,ctx,1);

                        await ctx.Images.AddAsync(await CreateRandomImage(ctx,breed.AlbumId,rng));

                        breed.Investment=rng.NextSingle();
                        breed.Territory=rng.NextSingle();
                        breed.Pricing=rng.NextSingle();
                        breed.Longevity=rng.NextSingle();
                        breed.Cohabitation=rng.NextSingle();

                        breed.Scale= scales[rng.Next(scales.Length)];

                        await ctx.AnimalBreeds.AddAsync(breed);

                        await ctx.SaveChangesAsync();
                    }


                    bool repeat_breed_shuffle = true;
                    while (repeat_breed_shuffle)
                    {
                        repeat_breed_shuffle = false;

                        foreach(Kind knd in kinds)
                        {
                            if(!await ctx.AnimalBreeds.AnyAsync(b => b.KindId == knd.Id))
                            {
                                repeat_breed_shuffle=true;

                                Breed? brd = await ctx.AnimalBreeds.OrderBy(b=>Guid.NewGuid()).FirstOrDefaultAsync();

                                if (brd != null)
                                {
                                    brd.KindId=knd.Id;
                                    await ctx.SaveChangesAsync();
                                }
                            }
                            
                        }
                        

                    }


                    await ctx.SaveChangesAsync();

                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I wish nothing more than to spend as many years as I can with my pet.",LongevityEffect=0.65f,PricingEffect=0.125f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I want a low-maintenance pet.",PricingEffect=-0.2f,InvestmentEffect=-0.35f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I have a large living space.",InvestmentEffect=-0.125f,TerritoryEffect=0.3f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I prefer the baby-era of pet ownership.",LongevityEffect=-0.35f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I have other pets at the moment.",CohabitationEffect=0.5f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I can only afford one pet.",CohabitationEffect=-0.2f,PricingEffect=-0.4f,LongevityEffect=-0.15f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I want a pet that adapts well to small living spaces.",TerritoryEffect=-0.5f,CohabitationEffect=0.2f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I enjoy outdoor activities with my pet.",TerritoryEffect=0.35f,InvestmentEffect=0.1f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I prefer pets that are quiet and unobtrusive.",TerritoryEffect=-0.125f,InvestmentEffect=-0.4f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I want a low-cost pet that still lives a long life.",PricingEffect=-0.25f,LongevityEffect=0.25f});
                    await ctx.LivingConditionFields.AddAsync(new LivingConditionField{Title="I like pets that require frequent engagement and play.",InvestmentEffect=0.35f,CohabitationEffect=0.15f,TerritoryEffect=0.2f});

                    await ctx.SaveChangesAsync();
                    
                    Procedure proc = new Procedure{Description="X-Virus vaccination"};
                    Procedure proc_two = new Procedure{Description="Fur trimming"};
                    await ctx.MedicalProcedures.AddAsync(proc);
                    await ctx.MedicalProcedures.AddAsync(proc_two);
                    await ctx.SaveChangesAsync();

                    Guid afflicted_kind_id = kinds[rng.Next(kinds.Count)].Id;
                    List<Breed> afflicted_breeds = await ctx.AnimalBreeds.Where(b=>b.KindId!=afflicted_kind_id).OrderBy(b => Guid.NewGuid()).Take(rng.Next(5,10)).ToListAsync();

                    afflicted_breeds = afflicted_breeds.Where(a=>a.KindId==afflicted_breeds[0].KindId).ToList();

                    await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc.Id,KindId=afflicted_kind_id,BreedId=null,SexSpecific=true,Optional=true,IntervalDays=50,ApproximateAge=280});

                    foreach(Breed afflicted_breed in afflicted_breeds)
                    {
                        await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc.Id,KindId=afflicted_breed.KindId,BreedId=afflicted_breed.Id,SexSpecific=null,Optional=false,IntervalDays=null,ApproximateAge=rng.Next(100,400)});
                        if ((rng.Next() & 0x1) == 1)
                        {
                            await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc_two.Id,KindId=afflicted_breed.KindId,BreedId=afflicted_breed.Id,SexSpecific=null,Optional=true,IntervalDays=null,ApproximateAge=rng.Next(100,400)});
                        }
                    }                   

                    await ctx.Announcements.AddAsync(new Announcement{Body="Users and employees can see this.",UserVisible=true,BusinessVisible=true});
                    await ctx.Announcements.AddAsync(new Announcement{Body="User specific.",UserVisible=true,BusinessVisible=false});
                    await ctx.Announcements.AddAsync(new Announcement{Body="Employee specific.",UserVisible=false,BusinessVisible=true});
                    await ctx.Announcements.AddAsync(new Announcement{Body="Internal modmail.",UserVisible=false,BusinessVisible=false});


                    foreach(Category cat in categories){
                        
                        Usage? usg_aff = await ctx.UsageEstimates.FirstOrDefaultAsync(u=>u.KindId==afflicted_kind_id && u.CategoryId==cat.Id);

                        if(usg_aff==null && cat.Consumable)
                        {
                            await ctx.UsageEstimates.AddAsync(new Usage{KindId=afflicted_kind_id,CategoryId=cat.Id,ScaleSpecific=null,AverageDailyAmountGrams=rng.Next(100,500)});
                        }

                    }
                    
                    await ctx.SaveChangesAsync();

                    if (non_static_data)
                    {
                        List<Account> Users = new();
                        List<Account> Employees = new();
                        List<Account> Admins = new();

                        for(int i =1; i<=31; i++)
                        {
                            Account acc = new();
                            User usr = new();
                            usr.UserName=await Utils.UserUtils.GenerateUsername(ctx);
                            acc.PasswordSalt=Utils.Crypto.GenerateSalt();
                            acc.PasswordHash=Utils.Crypto.GenerateHash("test",acc.PasswordSalt);
                            acc.Verified=true;

                            if (i < 11)
                            {
                                acc.Contact=$"user{i}@example.com";
                                acc.AccessLevel=Access.User;
                                Users.Add(acc);
                                
                            }
                            else if (i < 21)
                            {
                                acc.Contact=$"employee{i-10}@example.com";
                                acc.AccessLevel=Access.BusinessAccount;
                                Employees.Add(acc);
                            }
                            else if(i<31)
                            {
                                acc.Contact=$"admin{i-20}@example.com";
                                acc.AccessLevel=Access.Admin;
                                Admins.Add(acc);
                            }
                            else
                            {
                                acc.Verified=false;                                
                                acc.Contact="unverified@example.com";
                            }

                            if (i == 1)
                            {
                                acc.RegistrationDate=DateTime.UtcNow.AddDays(-10);
                            }

                            await ctx.Accounts.AddAsync(acc);
                            await ctx.SaveChangesAsync();
                            usr.Id=acc.Id;
                            await ctx.Users.AddAsync(usr);

                            if (!acc.Verified)
                            {
                                string salt = Crypto.GenerateSalt();
                                string hash = Crypto.GenerateHash("12345678",salt);

                                await ctx.Registrations.AddAsync(new Registration{Id=acc.Id,Expiry=DateTime.UtcNow.AddHours(1),NextAttempt=DateTime.UtcNow,CodeHash=hash,CodeSalt=salt});
                            }

                            await ctx.SaveChangesAsync();
                        }

                        Franchise franch = new Franchise{OwnerId=Employees[0].Id,Contact="mega@example.com",FranchiseName="MegaCorp"};
                        await ctx.Franchises.AddAsync(franch);

                        Franchise franch_two = new Franchise{OwnerId=Employees[0].Id,Contact="micro@example.com",FranchiseName="MicroCorp"};
                        await ctx.Franchises.AddAsync(franch_two);

                        Franchise off_franch = new Franchise{OwnerId=Employees[1].Id,Contact="offbrand@example.com",FranchiseName="OffCorp"};
                        await ctx.Franchises.AddAsync(off_franch);

                        await ctx.SaveChangesAsync();

                        await ctx.EmployeeRecords.AddAsync(new EmployeeRecord{FranchiseId=off_franch.Id,UserId=Employees[0].Id});
                       

                        await ctx.Notifications.AddAsync(new Notification{UserId=franch.OwnerId,FranchiseId=null,ListingId=null,Title="Notification - OWNER", Body="Only you, the owner, can see this notification."});
                        await ctx.Notifications.AddAsync(new Notification{UserId=franch.OwnerId,FranchiseId=franch.Id,ListingId=null,Title="Notification - FRANCHISE", Body="The franchise owner and employees can see this notification."});

                       

                        Facility facility = new Facility{Contact="mega.uk@example.com",City="London",Street="MainSt no.1",FranchiseId=franch.Id};
                        await ctx.Facilities.AddAsync(facility);

                        Facility facility_two = new Facility{Contact="mega.ie@example.com",City="Derry",Street="AdamsSt no.4",FranchiseId=franch.Id};
                        await ctx.Facilities.AddAsync(facility_two);

                        for(int i = 1; i<4; i++)
                        {
                            await ctx.EmployeeRecords.AddAsync(new EmployeeRecord{FranchiseId=franch.Id,UserId=Employees[i].Id});
                            await ctx.EmployeeRecords.AddAsync(new EmployeeRecord{FranchiseId=franch_two.Id,UserId=Employees[i].Id});
                        }

                        await ctx.SaveChangesAsync();
                        
                        for(int i = 0; i<4; i++)
                        {
                            if (template == null || template.Fields.Count == 0)
                            {
                                break;
                            }
                            bool visible = ((i&0x1)==0);
                            string base_name = (visible)? $"Visible{i}":$"Invisible{i}";
                            
                            Form frm = new Form{FormTemplateId=template.Id,UserId=Employees[0].Id,FranchiseName=$"{base_name}Corp",DefaultContact=$"{base_name.ToLower()}@example.com",AlbumId=await FormService.CreateAlbum(Employees[0].Id,ctx,1)};

                            await ctx.Forms.AddAsync(frm);

                            await ctx.SaveChangesAsync();

                            if (visible)
                            {
                                await ctx.Images.AddAsync(await CreateRandomImage(ctx,frm.AlbumId,rng));
                            }

                            foreach(FormTemplateField ftf in template.Fields)
                            {
                                await ctx.FormFieldEntries.AddAsync(new FormFieldEntry{FormId=frm.Id,FormTemplateFieldId=ftf.Id,Serialized=(ftf.Optional)?"":base_name});

                            }

                            await ctx.SaveChangesAsync();

                        }

                        List<Breed> breeds = await ctx.AnimalBreeds.Where(b=>b.KindId==kinds[0].Id||b.KindId==afflicted_kind_id).ToListAsync();

                        List<string> petNames = new List<string> { "Bella", "Max", "Luna", "Charlie",
                        "Daisy", "Rocky", "Coco", "Oliver", "Molly", "Leo", "Simba", "Lola", 
                        "Buddy", "Nala", "Toby", "Chloe", "Jack", "Sadie", "Milo", "Ruby" };

                        for(int i = 0; i < 100; i++)
                        {

                            bool owned = rng.Next(4)==1;

                            Individual animal = new Individual{Owned=owned,ShelterId=(owned)?null:franch.Id,OwnerId=(owned)?Users[rng.Next(1,Users.Count)].Id:null,Name=petNames[rng.Next(petNames.Count)],Sex=rng.Next(2)==1,BreedId=breeds[rng.Next(breeds.Count)].Id,AnimalIdentity=Guid.NewGuid(),BirthDate=DateTime.UtcNow.AddDays(-(rng.Next(100,1000)))};

                            await ctx.IndividualAnimals.AddAsync(animal);

                            if ((i & 0x3) == 0x3||((i&0x1)==0x1&&!animal.Owned))
                            {
                                await ctx.SaveChangesAsync();

                                await ctx.MedicalRecordEntries.AddAsync(new MedicalRecordEntry{AnimalId=animal.Id,ProcedureId=proc.Id,DatePerformed=animal.BirthDate.AddDays(rng.Next(100))});
                            }

                        }

                        Individual lolek = new Individual{Owned=true,ShelterId=null,OwnerId=Users[0].Id,Name="Lolek",Sex=true,BreedId=littleHamster.Id,AnimalIdentity=Guid.NewGuid(),BirthDate=DateTime.UtcNow.AddDays(-(rng.Next(500,1500)))};
                        Individual bolek= new Individual{Owned=true,ShelterId=null,OwnerId=Users[0].Id,Name="Bolek",Sex=true,BreedId=bigHamster.Id,AnimalIdentity=Guid.NewGuid(),BirthDate=DateTime.UtcNow.AddDays(-(rng.Next(500,1500)))}; 

                        await ctx.IndividualAnimals.AddAsync(lolek);
                        await ctx.IndividualAnimals.AddAsync(bolek);

                        for(int i = 0; i< kinds.Count; i++)
                        {
                            Breed? brd = await ctx.AnimalBreeds.FirstOrDefaultAsync(b=>b.KindId==kinds[i].Id);

                            if (brd != null)
                            {
                                if (brd.KindId == afflicted_breeds[0].KindId)
                                {
                                    brd=afflicted_breeds[0];
                                }

                                Individual animal_m = new Individual{Owned=true,ShelterId=null,OwnerId=Users[0].Id,Name=petNames[rng.Next(petNames.Count)],Sex=true,BreedId=brd.Id,AnimalIdentity=Guid.NewGuid(),BirthDate=DateTime.UtcNow.AddDays(-(rng.Next(500,1500)))};
                                Individual animal_f = new Individual{Owned=true,ShelterId=null,OwnerId=Users[0].Id,Name=petNames[rng.Next(petNames.Count)],Sex=false,BreedId=brd.Id,AnimalIdentity=Guid.NewGuid(),BirthDate=DateTime.UtcNow.AddDays(-(rng.Next(500,1500)))};
                                await ctx.IndividualAnimals.AddAsync(animal_m);
                                await ctx.IndividualAnimals.AddAsync(animal_f);
                            
                            };
                        }

                        await ctx.SupplyRecords.AddAsync(new Supplies{UserId=Users[0].Id, KindId = usage_kind.Id,CategoryId=usageCategory,MassGrams=1000,Evaluated= DateTime.Today.AddDays(-1)});

                        await ctx.SaveChangesAsync();

                        await ctx.MedicalRecordEntries.AddAsync(new MedicalRecordEntry{ProcedureId=proc.Id,AnimalId=lolek.Id});
                        await ctx.MedicalRecordEntries.AddAsync(new MedicalRecordEntry{ProcedureId=proc_two.Id,AnimalId=lolek.Id});
                        await ctx.MedicalRecordEntries.AddAsync(new MedicalRecordEntry{ProcedureId=proc.Id,AnimalId=bolek.Id});

                        List<LivingConditionField> livingConditions = await ctx.LivingConditionFields.ToListAsync();


                        foreach(Account acc in Users)
                        {
                            
                            int kind_c = rng.Next(kinds.Count);
                            int cat_c = rng.Next(categories.Count);

                            int wish_c = rng.Next(25);

                            if (acc == Users[0])
                            {
                                kind_c=kinds.Count;
                                cat_c=categories.Count;

                                wish_c=rng.Next(15,25);
                            }

                            for(int i = 0; i<kind_c; i++)
                            {
                                
                                for(int j = 0; j < cat_c; j++)
                                {
                                    int mass = rng.Next(1000);

                                    if((i&0x1)==0x1 && (j&0x1)==0x1 && acc.Id == Users[0].Id)
                                    {
                                        mass=0;
                                    }

                                    bool will_add = rng.Next(3)==2;

                                    if (categories[j].Consumable&&(will_add||acc.Id==Users[0].Id))
                                    {
                                        await ctx.SupplyRecords.AddAsync(new Supplies{UserId=acc.Id,CategoryId=categories[j].Id,KindId=kinds[i].Id,MassGrams=mass,Evaluated=DateTime.UtcNow.AddDays(-rng.Next(3))});

                                    }
                                    
                         
                                }

                            }

                            List<string> wishes = new();

                            for(int i=0; i < wish_c; i++)
                            {
                                string wish = productDescriptors[rng.Next(productDescriptors.Count)];

                                if (!wishes.Contains(wish))
                                {
                                    await ctx.Wishlists.AddAsync(new Wishlist{UserId=acc.Id,Term=wish});
                                    wishes.Add(wish);
                                }
                            }

                            foreach(LivingConditionField lvf in livingConditions)
                            {
                                
                                int answer = rng.Next(3);

                                if (answer < 2)
                                {

                                    await ctx.LivingConditionEntries.AddAsync(new LivingConditionEntry{UserId=acc.Id,LivingConditionFieldID=lvf.Id,Answer=answer==1});

                                }


                            }


                        }

                        await ctx.SaveChangesAsync();

                        List<Guid> generic_listing_album_ids = new();

                        for(int i = 0; i<5; i++)
                        {

                            generic_listing_album_ids.Add(await ListingService.CreateAlbum(franch.OwnerId,ctx,1));

                            if (i != 4)
                            {
                                await ctx.Images.AddAsync(await CreateRandomImage(ctx,generic_listing_album_ids[i],rng));
                                
                            }
                        }


                        List<string> Individual_desc = new List<string>
                        {
                            "Cute",
                            "Playful",
                            "Loyal",
                            "Friendly",
                            "Energetic"
                        };


                        Listing visible_medical = new Listing{Type= ListingType.Medical, FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[0],Status=EvaluationStatus.Approved,Visible=true,ListingName="Visible medical listing.",ListingDescription="Users should see this listing."};

                        await ctx.Listings.AddAsync(visible_medical);

                        await ctx.SaveChangesAsync();

                        await ctx.Discounts.AddAsync(new Discount{ListingId=visible_medical.Id,PercentDiscount=(byte)rng.Next(100)});

                        await ctx.MedicalListings.AddAsync(new MedicalListing{Id=visible_medical.Id,ProcedureId=proc.Id});

                        await ctx.ListingAvailable.AddAsync(new Available{ListingId=visible_medical.Id,FacilityId=facility.Id});


                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[1],Status=EvaluationStatus.Pending,Visible=true,ListingName="Approval pending listing.",ListingDescription="Admins should see this listing."});

                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[2],Status=EvaluationStatus.Denied,Visible=true,ListingName="Non-updated listing.",ListingDescription="Workers should see this listing."});

                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[3],Status=EvaluationStatus.Approved,Visible=false,ListingName="Generic invisible listing.",ListingDescription="Workers should see this listing."});

                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[4],Status=EvaluationStatus.Pending,Visible=true,ListingName="Image-free listing.",ListingDescription="Workers should see this listing."});

                        await ctx.SaveChangesAsync();


                        await ctx.Comments.AddAsync(new Comment{PosterId = Users[1].Id,ListingId=visible_medical.Id,Message="Feel free to report, or delete this review."});
                        await ctx.Comments.AddAsync(new Comment{PosterId = Users[2].Id,ListingId=visible_medical.Id,Message="Feel free to ban me as an admin over this review."});



                        for(int i = 0; i<3; i++){

                            await ctx.Notifications.AddAsync(new Notification{UserId=Users[i].Id,Title="Blank",Body="This notification does not link a listing."});
                            await ctx.Notifications.AddAsync(new Notification{UserId=Users[i].Id,Title="Not blank",Body="This notification links a listing.", ListingId = visible_medical.Id});

                            await ctx.Notifications.AddAsync(new Notification{UserId=Employees[i].Id,Title="Blank",Body="This notification does not link a listing."});
                            await ctx.Notifications.AddAsync(new Notification{UserId=Employees[i].Id,Title="Not blank",Body="This notification links a listing.", ListingId = visible_medical.Id});
                           
                        }

                        await ctx.SaveChangesAsync();

                        List<Listing> listings = new();

                        List<Individual> adoptable_animals = await ctx.IndividualAnimals.Include(i=>i.AnimalBreed).Where(a=>a.ShelterId==franch.Id).ToListAsync();

                        int adoptables = 0;
                        foreach(Individual ind in adoptable_animals)
                        {

                            adoptables++;
                            bool up_for_adoption = rng.Next(3)==2;

                            DateTime creation = DateTime.UtcNow.AddDays(-rng.Next(100));   
                            

                            if (up_for_adoption)
                            {
                                
                                Guid album_id = await ListingService.CreateAlbum(franch.OwnerId,ctx,1);
                                await ctx.Images.AddAsync(await CreateRandomImage(ctx,album_id,rng));



                                Listing new_listing = new Listing{Type=ListingType.Pet,FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=album_id,Status=EvaluationStatus.Approved,Visible=true,ListingName=$"{ind.Name}-{adoptables}",ListingDescription=GenerateLoremIpsum(rng.Next(500,1000),rng),Posted=creation};
                                await ctx.Listings.AddAsync(new_listing);

                                listings.Add(new_listing);
                                
                                await ctx.SaveChangesAsync();

                                await ctx.AnimalListings.AddAsync(new AnimalListing{Id=new_listing.Id,AnimalId=ind.Id});
                                                              

                            }
                      
                        }

                        List<Item> items = await ctx.Items.Include(i=>i.ItemCategory).ToListAsync();
                        int marketables = 0;

                        foreach(Item itm in items)
                        {
                            marketables ++;
                            
                           

                            byte amount = (byte)rng.Next(2,15);

                            DateTime creation = DateTime.UtcNow.AddDays(-rng.Next(100));   
                            

                             
                            Guid album_id = await ListingService.CreateAlbum(franch.OwnerId,ctx,1);
                            await ctx.Images.AddAsync(await CreateRandomImage(ctx,album_id,rng));

                            Listing new_listing = new Listing{Type=ListingType.Product,FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=album_id,Status=EvaluationStatus.Approved,Visible=true,ListingName=$"{itm.Title}-{marketables}",ListingDescription=$"A great choice of {itm.ItemCategory.Title} for yout pet.",Posted=creation};
                            await ctx.Listings.AddAsync(new_listing);

                            listings.Add(new_listing);
                            
                            await ctx.SaveChangesAsync();

                            await ctx.ProductListings.AddAsync(new ProductListing{Id=new_listing.Id,ProductId=itm.Id,PerListing=amount});
                                                              

                            

                        }


                             
                        Guid usage_album_id = await ListingService.CreateAlbum(franch.OwnerId,ctx,1);
                        await ctx.Images.AddAsync(await CreateRandomImage(ctx,usage_album_id,rng));

                        Listing usage_listing = new Listing{Type=ListingType.Product,FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=usage_album_id,Status=EvaluationStatus.Approved,Visible=true,ListingName=$"Hamster product for sale",ListingDescription=$"Why do people even get hamsters?",Posted=DateTime.UtcNow};
                        await ctx.Listings.AddAsync(usage_listing);

                        
                            
                        await ctx.SaveChangesAsync();

                        await ctx.ProductListings.AddAsync(new ProductListing{Id=usage_listing.Id,ProductId=hamsterItem.Id,PerListing=2});
                                                              

                            


                        for(int i = 0;i<5; i++)
                        {
                            
                            int price = rng.Next(12345);
                            DateTime creation = DateTime.UtcNow.AddDays(-rng.Next(100));                          

                            
                            Guid album_id = await ListingService.CreateAlbum(franch.OwnerId,ctx,1);
                            await ctx.Images.AddAsync(await CreateRandomImage(ctx,album_id,rng));

                            Listing new_listing = new Listing{Type=ListingType.Generic,FranchiseId=franch.Id,PriceMinor=price,AlbumId=album_id,Status=EvaluationStatus.Approved,Visible=true,ListingName=$"Generic listing no. {i}",ListingDescription=$"Test.",Posted=creation};
                            await ctx.Listings.AddAsync(new_listing);

                            listings.Add(new_listing);                              
                                                         
                            
                            await ctx.SaveChangesAsync();    

                            await ctx.ListingAvailable.AddAsync(new Available{ListingId=new_listing.Id,FacilityId=facility.Id});                 
                        }


                        await ctx.SaveChangesAsync();


                        List<string> commentBodies = new List<string>
                        {
                            "Looks great.",                            
                            "Very satisfied.",
                            "Seems like a scam.",
                            "Do NOT recommend!",
                            "http://www.malicious_link.com",
                            "Very happy.",
                            "Nice.",
                            "Just what I needed.",
                        };


                        Listing? orphanBlobListing = await ctx.Listings.FirstOrDefaultAsync(l=>l.Type==ListingType.Generic);

                        if (orphanBlobListing != null)
                        {
                            listings.Remove(orphanBlobListing);
                            await orphanBlobListing.StageDeletion<Listing>(ctx,ctx.Listings);
                        }

                        await ctx.SaveChangesAsync();

                        List<Comment> comments = new();


                        for(int i=1; i < Users.Count; i++)
                        {
                            foreach(Listing l in listings)
                            {
                                if (rng.Next(4) == 3)
                                {
                                    
                                    Comment cmt = new Comment{PosterId=Users[i].Id,ListingId=l.Id,Message=commentBodies[rng.Next(commentBodies.Count)]};

                                    await ctx.Comments.AddAsync(cmt);

                                    comments.Add(cmt);


                                }
                                

                            }

                        }


                        await ctx.SaveChangesAsync();

                        List<Guid> reported_listings = new();

                        for(int i = 0; i < comments.Count; i++)
                        {
                            
                            int choice = i&0x7;

                            if (!reported_listings.Contains(comments[i].ListingId))
                            {
                                
                           

                                switch (choice)
                                {
                                    case 0 : {
                                        await ctx.Reports.AddAsync(new Report{ReporterId=Users[0].Id,Reason="Listing.",ListingId=comments[i].ListingId,CommentId=null});
                                        reported_listings.Add(comments[i].ListingId);
                                        break;
                                    }
                                    case 1 : {
                                        await ctx.Reports.AddAsync(new Report{ReporterId=Users[0].Id,Reason="Comment only.",ListingId=comments[i].ListingId,CommentId=comments[i].Id});
                                        reported_listings.Add(comments[i].ListingId);
                                        break;
                                    }

                                    default: {break;}
                                }

                            }


                        }

                        await ctx.SaveChangesAsync();

                        List<Album> reserved_albums = await ctx.Albums.Where(a => a.Images.Any()).ToListAsync();

                        foreach(Album alb in reserved_albums)
                        {
                            alb.Reserved=1;
                        }

                        await ctx.SaveChangesAsync();


                        List<Album> locked = await ctx.Albums.Where(a=> ctx.Listings.Any(l=>l.AlbumId==a.Id && l.Status==EvaluationStatus.Approved) && a.Reserved!=0).ToListAsync();

                        foreach(Album lockedAlbum in locked)
                        {
                            lockedAlbum.Locked=true;
                        }


                    }                    

                  
                    await ctx.SaveChangesAsync();


                    await tx.CommitAsync();
                    return true;
                }
                catch(Exception ex)
                {
                    if (logger != null)
                    {
                        logger.LogError(ex,"Seeder exception.");
                    }
                    await tx.RollbackAsync();                    
                    return false;
                }
            }

        }

    }


}