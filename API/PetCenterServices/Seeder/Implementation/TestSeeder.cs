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

        public PetCenterModels.DBTables.Image CreateRandomImage(Guid album_id,Random rng, short w = 32, short h=32)
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

        public async Task<bool> SeedDatabase(PetCenterDBContext ctx, bool non_static_data,int? seed)
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

            using(IDbContextTransaction tx = await ctx.Database.BeginTransactionAsync())
            {
                try
                {
                    Random rng = new();

                    if (seed != null)
                    {
                        rng=new Random((int)seed);
                    }

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
                    await ctx.MedicalProcedures.AddAsync(proc);
                    await ctx.SaveChangesAsync();

                    Guid afflicted_kind_id = kinds[rng.Next(kinds.Count)].Id;
                    List<Breed> afflicted_breeds = await ctx.AnimalBreeds.Where(b=>b.KindId!=afflicted_kind_id).OrderBy(b => Guid.NewGuid()).Take(rng.Next(5,10)).ToListAsync();

                    afflicted_breeds = afflicted_breeds.Where(a=>a.KindId==afflicted_breeds[0].KindId).ToList();

                    await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc.Id,KindId=afflicted_kind_id,BreedId=null,SexSpecific=true,Optional=true,IntervalDays=50,ApproximateAge=280});

                    foreach(Breed afflicted_breed in afflicted_breeds)
                    {
                        await ctx.MedicalProcedureSpecifications.AddAsync(new MedicalProcedureSpecification{ProcedureId=proc.Id,KindId=afflicted_breed.KindId,BreedId=afflicted_breed.Id,SexSpecific=null,Optional=false,IntervalDays=null,ApproximateAge=rng.Next(100,400)});
                    }                   

                    await ctx.Announcements.AddAsync(new Announcement{Body="Users and employees can see this.",UserVisible=true,BusinessVisible=true,Expiry=DateTime.UtcNow.AddDays(3)});
                    await ctx.Announcements.AddAsync(new Announcement{Body="Users specific.",UserVisible=true,BusinessVisible=false,Expiry=DateTime.UtcNow.AddDays(3)});
                    await ctx.Announcements.AddAsync(new Announcement{Body="Employee specific.",UserVisible=false,BusinessVisible=true,Expiry=DateTime.UtcNow.AddDays(3)});
                    await ctx.Announcements.AddAsync(new Announcement{Body="Internal modmail.",UserVisible=false,BusinessVisible=false,Expiry=DateTime.UtcNow.AddDays(3)});


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

                            await ctx.Accounts.AddAsync(acc);
                            await ctx.SaveChangesAsync();
                            usr.Id=acc.Id;
                            await ctx.Users.AddAsync(usr);

                            if (!acc.Verified)
                            {
                                await ctx.Registrations.AddAsync(new Registration{AccountId=acc.Id,Expiry=DateTime.UtcNow.AddHours(1),NextAttempt=DateTime.UtcNow,Code=12345678});
                            }

                            await ctx.SaveChangesAsync();
                        }

                        Franchise franch = new Franchise{OwnerId=Employees[0].Id,Contact="mega@example.com",FranchiseName="MegaCorp"};
                        await ctx.Franchises.AddAsync(franch);

                        await ctx.SaveChangesAsync();

                        await ctx.Notifications.AddAsync(new Notification{UserId=franch.OwnerId,FranchiseId=null,ListingId=null,Title="Notification - OWNER", Body="Only you can see this notification."});
                        await ctx.Notifications.AddAsync(new Notification{UserId=franch.OwnerId,FranchiseId=franch.Id,ListingId=null,Title="Notification - FRANCHISE", Body="You and your employees can see this notification."});


                        Facility facility = new Facility{Contact="mega.uk@example.com",City="London",Street="MainSt no.1",FranchiseId=franch.Id};
                        await ctx.Facilities.AddAsync(facility);

                        for(int i = 1; i<4; i++)
                        {
                            await ctx.EmployeeRecords.AddAsync(new EmployeeRecord{FranchiseId=franch.Id,UserId=Employees[i].Id});
                        }

                        await ctx.SaveChangesAsync();
                        
                        for(int i = 0; i<2; i++)
                        {
                            if (template == null || template.Entries.Count == 0)
                            {
                                break;
                            }
                            bool visible = i==0;
                            string base_name = (visible)? "Visible":"Invisible";
                            
                            Form frm = new Form{FormTemplateId=template.Id,UserId=Employees[0].Id,FranchiseName=$"{base_name}Corp",DefaultContact=$"{base_name.ToLower()}@example.com",AlbumId=await ImageService.CreateAlbum(Employees[0].Id,ctx,1)};

                            await ctx.Forms.AddAsync(frm);

                            await ctx.SaveChangesAsync();

                            if (visible)
                            {
                                await ctx.Images.AddAsync(CreateRandomImage(frm.AlbumId,rng));
                            }

                            foreach(FormTemplateField ftf in template.Entries)
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

                        

                        await ctx.SaveChangesAsync();

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
                                        await ctx.SupplyRecords.AddAsync(new Supplies{UserId=acc.Id,CategoryId=categories[j].Id,KindId=kinds[i].Id,MassGrams=mass,Evaluated=DateTime.UtcNow.AddHours(-rng.Next(24))});

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

                            generic_listing_album_ids.Add(await ImageService.CreateAlbum(franch.OwnerId,ctx,1));

                            if (i != 4)
                            {
                                await ctx.Images.AddAsync(CreateRandomImage(generic_listing_album_ids[i],rng));
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


                        Listing visible_medical = new Listing{Type= ListingType.Medical, FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[0],Approved=true,Updated=false,Visible=true,ListingName="Visible medical listing.",ListingDescription="Users should see this listing."};

                        await ctx.Listings.AddAsync(visible_medical);

                        await ctx.SaveChangesAsync();

                        await ctx.MedicalListings.AddAsync(new MedicalListing{Id=visible_medical.Id,ProcedureId=proc.Id});

                        await ctx.ListingAvailable.AddAsync(new Available{ListingId=visible_medical.Id,FacilityId=facility.Id});


                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[1],Approved=false,Updated=true,Visible=true,ListingName="Approval pending listing.",ListingDescription="Admins should see this listing."});

                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[2],Approved=false,Updated=false,Visible=true,ListingName="Non-updated listing.",ListingDescription="Workers should see this listing."});

                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[3],Approved=true,Updated=false,Visible=false,ListingName="Generic invisible listing.",ListingDescription="Workers should see this listing."});

                        await ctx.Listings.AddAsync(new Listing{FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=generic_listing_album_ids[4],Approved=false,Updated=true,Visible=true,ListingName="Image-free listing.",ListingDescription="Workers should see this listing."});

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
                                
                                Guid album_id = await ImageService.CreateAlbum(franch.OwnerId,ctx,1);
                                await ctx.Images.AddAsync(CreateRandomImage(album_id,rng));



                                Listing new_listing = new Listing{Type=ListingType.Pet,FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=album_id,Approved=true,Updated=false,Visible=true,ListingName=$"{ind.Name}-{adoptables}",ListingDescription=$"{Individual_desc[rng.Next(Individual_desc.Count)]} {ind.AnimalBreed.Title} for adoption.",Posted=creation};
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
                            
                            bool for_sale = rng.Next(3)==2;

                            byte amount = (byte)rng.Next(2,15);

                            DateTime creation = DateTime.UtcNow.AddDays(-rng.Next(100));   
                            

                            if (for_sale)
                            {
                                
                                Guid album_id = await ImageService.CreateAlbum(franch.OwnerId,ctx,1);
                                await ctx.Images.AddAsync(CreateRandomImage(album_id,rng));

                                Listing new_listing = new Listing{Type=ListingType.Product,FranchiseId=franch.Id,PriceMinor=rng.Next(10000),AlbumId=album_id,Approved=true,Updated=false,Visible=true,ListingName=$"{itm.Title}-{marketables}",ListingDescription=$"A great choice of {itm.ItemCategory.Title} for yout pet.",Posted=creation};
                                await ctx.Listings.AddAsync(new_listing);

                                listings.Add(new_listing);
                                
                                await ctx.SaveChangesAsync();

                                await ctx.ProductListings.AddAsync(new ProductListing{Id=new_listing.Id,ProductId=itm.Id,PerListing=amount});
                                                              

                            }

                        }


                        for(int i = 0;i<5; i++)
                        {
                            
                            int price = rng.Next(12345);
                            DateTime creation = DateTime.UtcNow.AddDays(-rng.Next(100));                          

                            
                            Guid album_id = await ImageService.CreateAlbum(franch.OwnerId,ctx,1);
                            await ctx.Images.AddAsync(CreateRandomImage(album_id,rng));

                            Listing new_listing = new Listing{Type=ListingType.Generic,FranchiseId=franch.Id,PriceMinor=price,AlbumId=album_id,Approved=true,Updated=false,Visible=true,ListingName=$"Generic listing no. {i}",ListingDescription=$"Test.",Posted=creation};
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
                                        await ctx.Reports.AddAsync(new Report{ReporterId=Users[0].Id,Expiry=DateTime.UtcNow.AddDays(rng.Next(1,4)),Reason="Listing.",ListingId=comments[i].ListingId,CommentId=null});
                                        reported_listings.Add(comments[i].ListingId);
                                        break;
                                    }
                                    case 1 : {
                                        await ctx.Reports.AddAsync(new Report{ReporterId=Users[0].Id,Expiry=DateTime.UtcNow.AddDays(rng.Next(1,4)),Reason="Comment only.",ListingId=comments[i].ListingId,CommentId=comments[i].Id});
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