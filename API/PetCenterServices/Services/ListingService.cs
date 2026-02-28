using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterServices.Recommender;


namespace PetCenterServices.Services
{
    public class ListingService : AlbumIncludingService<Listing,ListingSearchObject,ListingRequestDTO,ListingResponseDTO>, IListingService    
    {
        private readonly IRecommenderSystem recommender;

        public ListingService(PetCenterDBContext ctx, IRecommenderSystem rec) : base(ctx)
        {
            dbSet = ctx.Listings;
            recommender = rec;
        }

        protected override Task<IQueryable<Listing>> Filter(Guid token_holder, ListingSearchObject search)
        {
            
            IQueryable<Listing> query = WithAlbum().Include(l=>l.Comments).ThenInclude(c=>c.Poster).Include(l=>l.AvailabilityRecords).ThenInclude(a=>a.RelevantFacility).Include(l=>l.ListingDiscount)
            .Include(l=>l.AnimalExtension).ThenInclude(a=>a!.Animal).Include(l=>l.MedicalExtension).ThenInclude(m=>m!.Procedure).ThenInclude(mp=>mp.Specifications).Include(l=>l.ProductExtension).ThenInclude(p=>p!.Product).ThenInclude(pr=>pr.ItemCategory);

            switch (search.AuthoritySpecifier)
            {
                case Access.User: {query=query.Where(q=>q.Visible&&q.Approved&&q.Album!=null&&q.Album.Reserved>0);break;}
                case Access.Admin: {query=query.Where(q=>q.Album!=null&&q.Album.Reserved>0&&((!q.Approved&&q.Updated)||search.ShowApprovedAndPending));break;}
                case Access.BusinessAccount : { query = query.Where(q =>
                q.Business.OwnerId == token_holder ||
                q.Business.EmployeeRecords.Any(e => e.UserId == token_holder));
                break; }
                default : {break;}
            }

            if (search.AuthoritySpecifier == Access.User)
            {
                
                switch (search.Type)
                {
                    case ListingType.Product: {query = query.Where(q=>q.ProductExtension!=null&&q.ProductExtension.Product!=null&&q.ProductExtension.Product.CategoryId==search.RelevantId&&q.ProductExtension.Product.KindId==search.KindSpecific && (q.ProductExtension.Product.TargetScale==null||q.ProductExtension.Product.TargetScale==search.ScaleSpecific));break;}
                    case ListingType.Medical: {query = query.Where(q=>q.MedicalExtension!=null&&q.MedicalExtension.Procedure!=null&&q.MedicalExtension.ProcedureId==search.RelevantId&&q.MedicalExtension.Procedure.Specifications.Any(s=>(s.BreedId==search.BreedSpecific&&s.ApproximateAge!=null&&(s.SexSpecific==null||s.SexSpecific==search.SexSpecific))||(s.BreedId==null&&s.KindId==search.KindSpecific && s.ApproximateAge!=null&&(s.SexSpecific==null||s.SexSpecific==search.SexSpecific)))&&!q.MedicalExtension.Procedure.Specifications.Any(s=>s.BreedId==search.BreedSpecific&&s.ApproximateAge==null&&(s.SexSpecific==null||s.SexSpecific==search.SexSpecific)));break;}
                    case ListingType.Pet: {query = query.Where(q=>q.AnimalExtension!=null&&q.AnimalExtension.Animal!=null&&q.AnimalExtension.Animal.BreedId==search.RelevantId);break;}            
                }

                

            }


            switch (search.OrderBy)
            {
                case OrderingMethod.ID : {query=query.OrderBy(q=>q.Id);break;}
                case OrderingMethod.PriceAscending : {query=query.OrderBy(q=>(q.ListingDiscount!=null)?((q.PriceMinor*100)-(q.PriceMinor*(long)q.ListingDiscount.PercentDiscount)):q.PriceMinor);break;}
                case OrderingMethod.PriceDescending : {query=query.OrderByDescending(q=>(q.ListingDiscount!=null)?((q.PriceMinor*100)-(q.PriceMinor*(long)q.ListingDiscount.PercentDiscount)):q.PriceMinor);break;}
            }

            return Task.FromResult(query);
                       
        }

        public override async Task<ServiceOutput<ListingResponseDTO>> GetById(Guid token_holder, Guid id, Access authorization_level)
        {
            Listing? output = await WithAlbum().Include(l=>l.Comments).ThenInclude(c=>c.Poster).Include(l=>l.AvailabilityRecords).ThenInclude(a=>a.RelevantFacility).Include(l=>l.ListingDiscount)
            .Include(l=>l.AnimalExtension).ThenInclude(a=>a!.Animal).Include(l=>l.MedicalExtension).ThenInclude(m=>m!.Procedure).ThenInclude(mp=>mp.Specifications).Include(l=>l.ProductExtension).ThenInclude(p=>p!.Product).ThenInclude(pr=>pr.ItemCategory).FirstOrDefaultAsync(l=>l.Id==id);

            ListingResponseDTO? dto = ListingResponseDTO.FromEntity(output);

            if (output == null || dto==null)
            {
                return ServiceOutput<ListingResponseDTO>.Error(HttpCode.NotFound,"This listing does not exist.");
            }

            if (authorization_level == Access.Admin)
            {
                if (output.Album == null || output.Album.Reserved <= 0)
                {
                    return ServiceOutput<ListingResponseDTO>.Error(HttpCode.Forbidden,"This listing is not ready for evaluation.");
                }
            }

            else if (authorization_level == Access.User)
            {

                if (!output.Visible || !output.Approved || output.Album == null || output.Album.Reserved <= 0)
                {
                    return ServiceOutput<ListingResponseDTO>.Error(HttpCode.Forbidden,"This listing is not currently present in the market.");   
                }

                

                if (output.Type == ListingType.Product && output.ProductExtension!=null && output.ProductExtension.Product!=null && output.ProductExtension.Product.ItemCategory!=null)
                {
                    Supplies? sup = await dbContext.SupplyRecords.FirstOrDefaultAsync(s=>s.UserId==token_holder && s.CategoryId==output.ProductExtension.Product.CategoryId && s.KindId==output.ProductExtension.Product.KindId);

                    int supplies = sup?.MassGrams ?? 0;

                    int usage = await Utils.UserUtils.GetTotalDailyUsageForCategory(dbContext,output.ProductExtension.Product.CategoryId,output.ProductExtension.Product.KindId,await dbContext.IndividualAnimals.Where(i=>i.OwnerId==token_holder).ToListAsync());

                    dto.Notes= new List<NoteSubDTO>{await recommender.AddUsageInfoToProductListing(dbContext,output.ProductExtension,usage,supplies)};
                }
            }

            else
            {
                if(!await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, output.FranchiseId))
                {
                    return ServiceOutput<ListingResponseDTO>.Error(HttpCode.Forbidden,"This listing was not made by a franchise you are employed by.");   
                }
            }
          
            return ServiceOutput<ListingResponseDTO>.Success(dto);
        }

       

    }

       
}
