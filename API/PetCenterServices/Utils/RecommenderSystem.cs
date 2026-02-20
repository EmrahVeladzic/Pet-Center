using Microsoft.EntityFrameworkCore;
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

namespace PetCenterServices.Recommender
{

    public class RecommenderSystem : IRecommenderSystem
    {
        
        public Expression<Func<Breed, float>>BuildDistanceExpression(PetCenterVector5 IdealVector)
        {
            return b =>
            (b.Investment     - IdealVector.Investment)     * (b.Investment     - IdealVector.Investment) +
            (b.Territory      - IdealVector.Territory)      * (b.Territory      - IdealVector.Territory) +
            (b.Pricing        - IdealVector.Pricing)        * (b.Pricing        - IdealVector.Pricing) +
            (b.Longevity      - IdealVector.Longevity)      * (b.Longevity      - IdealVector.Longevity) +
            (b.Cohabitation   - IdealVector.Cohabitation)   * (b.Cohabitation   - IdealVector.Cohabitation);
        }

        public async Task<IQueryable<Breed>> GetMostCompatibleBreeds(PetCenterDBContext ctx, IQueryable<Breed> filter, User user)
        {
            PetCenterVector5 ideal = new(await ctx.LivingConditionEntries.Include(e=>e.Field).Where(e=>e.UserId==user.Id).ToListAsync());
            Expression<Func<Breed, float>>  expression = BuildDistanceExpression(ideal);
            return filter.OrderBy(expression);
        }

        public async Task RecommendListingToUsers(PetCenterDBContext ctx, Discount discount)
        {
            ProductListing? listing = await ctx.ProductListings.Include(l=>l.Product).FirstOrDefaultAsync(l=>l.Id == discount.ListingId);
            if (listing != null && listing.Product!=null)
            {
                string ProductTitle = listing.Product.Title.ToLowerInvariant();
                List<Wishlist> wishlists = await ctx.Wishlists.Include(w=>w.RelevantUser).ThenInclude(r=>r.OwnedAnimals).ThenInclude(o=>o.AnimalBreed).Where(w=>ProductTitle.Contains(w.Term.ToLowerInvariant())).ToListAsync();
                wishlists = wishlists.Where(w=>w.RelevantUser!=null && w.RelevantUser.OwnedAnimals.Any(o=>o.AnimalBreed!=null && o.AnimalBreed.KindId==listing.Product.TargetKind && (listing.Product.TargetScale==null||listing.Product.TargetScale==o.AnimalBreed.Scale))).ToList();


                int progress = 0;
                foreach(Wishlist w in wishlists)
                {
                    Notification notif = new();
                    notif.UserId=w.UserId;
                    notif.FranchiseId=null;
                    notif.ListingId = discount.ListingId;
                    notif.Expiry=discount.Expiry;
                    notif.Title = $"Discount - {w.Term}";
                    notif.Body = $"A new discount of {(int)discount.PercentDiscount}% has been applied to a product you might want.";
                    
                    await ctx.Notifications.AddAsync(notif);

                    progress++;
                    if (progress >= 100)
                    {
                        progress=0;
                        await ctx.SaveChangesAsync();
                    }
                }
                await ctx.SaveChangesAsync();
            }
            
        }

        public async Task<List<NoteSubDTO>> AddNotesToPet(PetCenterDBContext ctx, Individual pet){
            
            List<NoteSubDTO> output = new();

            Breed? breed = await ctx.AnimalBreeds.FindAsync(pet.BreedId);
            if(breed==null){return output;}
            List<MedicalProcedureSpecification> specs = await ctx.MedicalProcedureSpecifications.Include(m=>m.MedicalProcedure).Where(m=>m.BreedId==pet.BreedId && (m.SexSpecific==null || m.SexSpecific==pet.Sex) && (m.ApproximateAge!=null || m.ApproximateAge<=(DateTime.UtcNow-pet.BirthDate).Days)).ToListAsync();
            specs.AddRange(await ctx.MedicalProcedureSpecifications.Include(m=>m.MedicalProcedure).Where(m=>m.KindId==breed.KindId && (m.SexSpecific==null || m.SexSpecific==pet.Sex) && m.ApproximateAge!=null && m.ApproximateAge<=(DateTime.UtcNow-pet.BirthDate).Days && !specs.Any(s=>s.ProcedureId==m.ProcedureId)).ToListAsync());

            specs = specs.Where(s=>s.MedicalProcedure!=null && s.ApproximateAge!=null).ToList();

            List<MedicalRecordEntry> entries = await ctx.MedicalRecordEntries.Where(e=>e.AnimalId==pet.Id).ToListAsync();

            specs = specs.Where(s=>!((s.IntervalDays==null&&entries.Any(e=>e.ProcedureId==s.ProcedureId))||(s.IntervalDays!=null && entries.Any(e=>e.ProcedureId==s.ProcedureId&&(DateTime.UtcNow-e.DatePerformed).Days<s.IntervalDays)))).OrderBy(s=>s.Optional).ThenBy(s=>s.ApproximateAge).ToList();

            foreach(MedicalProcedureSpecification specification in specs)
            {
                NoteSubDTO note = new();

                string previous = (specification.IntervalDays==null)? "a":"another";
                note.Title = (specification.Optional)? $"Medical - optional - {specification.MedicalProcedure.Description}" : $"Medical - IMPORTANT - {specification.MedicalProcedure.Description}";
                note.Body = $"{pet.Name} is due to have {previous} {specification.MedicalProcedure.Description} performed.";

                output.Add(note);

            }


            return output;

        }

        public async Task<NoteSubDTO> AddUsageInfoToProductListing(PetCenterDBContext ctx, ProductListing listing, int usage, int supplies)
        {
            NoteSubDTO output = new();
            output.Title = "Usage: ";
            output.Body= "You might not need this product.";

            if(listing.Product==null|| listing.Product.ItemCategory==null || usage == 0){return output;}

            if (!listing.Product.ItemCategory.Consumable)
            {
                output.Title = "Note: ";
                output.Body = "Make sure this item is fitting for your pet(s).";
                return output;
            }


            int days_remaining = supplies/usage;
            int listing_days = (listing.Product.MassGrams*(int)listing.PerListing)/usage;
            string plural = (listing_days==1)?"day":"days";


            output.Body = $"This product would last you {listing_days} {plural}. Your current supplies will last for {days_remaining}.";
            
            await Task.CompletedTask;
            return output;
        }
        
        public async Task<NoteSubDTO> ShoppingList(PetCenterDBContext ctx, Guid UserId){

            NoteSubDTO output = new();
            output.Title="Supplies you may need to restock on:";

            List<Individual> Animals = await ctx.IndividualAnimals.Include(i=>i.AnimalBreed).Where(i=>i.OwnerId==UserId).ToListAsync();
            List<Supplies> supplies = await ctx.SupplyRecords.Include(s=>s.KindDetails).Include(s=>s.ConsumableCategory).Where(s=>s.UserId==UserId).ToListAsync();
            Animals = Animals.Where(a=>a.AnimalBreed!=null).ToList();

            List<Kind> kinds= await ctx.AnimalKinds.Where(k=>Animals.Any(a=>a.AnimalBreed.KindId==k.Id)).ToListAsync();

                        
            supplies = supplies.Where(s=>s.ConsumableCategory!=null && s.KindDetails!=null).ToList();

            List<string> items = new();

            for(int k = 0; k<kinds.Count; k++)
            {
                string kind_title =kinds[k].Title.ToLowerInvariant();
                                 
                for(int s = 0; s<supplies.Count; s++)
                {
                    int daily_usage = await Utils.UserUtils.GetTotalDailyUsageForCategory(ctx,supplies[s].CategoryId,kinds[k].Id,Animals.Where(a=>a.AnimalBreed.KindId==kinds[k].Id).ToList());
                    if(daily_usage>0 && supplies[s].MassGrams / daily_usage < 7)
                    {
                        items.Add($"{supplies[s].ConsumableCategory.Title} for {kind_title}");
                                
                    }

                }

            }

            if (items.Any())
            {
                output.Body = string.Join("; ",items)+".";
            }
            else{
                output.Body = "You are stocked on everything you may need for the next week.";
            }

            return output;

        }


    }


}