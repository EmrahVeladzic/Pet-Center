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

        public override async Task<ServiceOutput<List<ListingResponseDTO>>> Get(Guid token_holder, ListingSearchObject search)
        {
            IQueryable<Listing> query = await Filter(token_holder,search);
            List<Listing> entities = await query.Skip(search.Page*search.PageSize).Take(search.PageSize).ToListAsync();
            List<ListingResponseDTO> output = entities.Select(l=>ListingResponseDTO.FromEntity(l)!).ToList();

            if (search.AuthoritySpecifier == Access.User)
            {

                if (search.Type == ListingType.Product)
                {
                    
                    Supplies? sup = await dbContext.SupplyRecords.FirstOrDefaultAsync(s=>s.UserId==token_holder && s.CategoryId==search.RelevantId && s.KindId==search.KindSpecific);

                    int supplies = sup?.MassGrams ?? 0;

                    int usage = await Utils.UserUtils.GetTotalDailyUsageForCategory(dbContext,search.RelevantId,search.KindSpecific,await dbContext.IndividualAnimals.Where(i=>i.OwnerId==token_holder).ToListAsync());
                
                    for(int i = 0; (i< output.Count && i<entities.Count); i++)
                    {
                        if (entities[i]!=null && output[i]!=null && entities[i].ProductExtension != null)
                        {
                            output[i].Notes=new();
                        
                            output[i].Notes!.Add(await recommender.AddUsageInfoToProductListing(dbContext,entities[i].ProductExtension!,usage,supplies));
                        }
                    }
                
                }



            }

            return ServiceOutput<List<ListingResponseDTO>>.Success(output);
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


        public async Task <ServiceOutput<CommentResponseSubDTO>> SendReview(Guid token_holder, Guid ListingId, string message)
        {
            if (string.IsNullOrWhiteSpace(message))
            {
                return ServiceOutput<CommentResponseSubDTO>.Error(HttpCode.BadRequest,"You cannot send an empty review.");
            }

            Comment? comment = await dbContext.Comments.FirstOrDefaultAsync(c=>c.PosterId==token_holder && c.ListingId==ListingId);

            if (comment != null)
            {
                comment.Message=message;
                comment.LastEditDate=DateTime.UtcNow;  
                await dbContext.SaveChangesAsync();  
                return ServiceOutput<CommentResponseSubDTO>.Success(CommentResponseSubDTO.FromEntity(comment));        
            }
            else
            {
                Listing? listing = await dbSet.FindAsync(ListingId);
                if (listing == null)
                {
                    return ServiceOutput<CommentResponseSubDTO>.Error(HttpCode.NotFound,"The selected listing does not exist.");
                }

                Comment new_comment = new();
                new_comment.ListingId=ListingId;
                new_comment.PosterId=token_holder;
                new_comment.Message=message;
                new_comment.LastEditDate = DateTime.UtcNow;
                await dbContext.Comments.AddAsync(new_comment);
                await dbContext.SaveChangesAsync();
                comment=new_comment;
                return ServiceOutput<CommentResponseSubDTO>.Success(CommentResponseSubDTO.FromEntity(comment),HttpCode.Created);
            }
            
        }

        public async Task<ServiceOutput<object>> RemoveReview(Guid token_holder, Guid comment_id, Access authorization_level)
        {
            Comment? comment = await dbContext.Comments.FindAsync(comment_id);

            if (comment != null)
            {
                
                if(authorization_level==Access.Admin || comment.PosterId == token_holder)
                {
                    await comment.StageDeletion<Comment>(dbContext,dbContext.Comments);
                    await dbContext.SaveChangesAsync();
                }
                else
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not have the permission to delete this comment.");
                }

            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

        public async Task <ServiceOutput<object>> Approve (Guid ListingId)
        {
            Listing? listing = await dbSet.Include(l=>l.Album).FirstOrDefaultAsync(l=>l.Id==ListingId);

            if (listing != null)
            {
                if (listing.Album == null || listing.Album.Reserved <= 0)
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You may not approve listings without images.");
                }

                listing.Approved=true;
                listing.Visible=true;
                listing.Album.Locked=true;
                await dbContext.SaveChangesAsync();
                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
            }
            return ServiceOutput<object>.Error(HttpCode.NotFound,"The selected listing does not exist.");
        }

        public async Task <ServiceOutput<object>> SetVisibility(Guid token_holder, Guid ListingId, bool visible)
        {
            
            Listing? listing = await dbSet.FindAsync(ListingId);

            if (listing != null)
            {
                if(! await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, listing.FranchiseId))
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You may not modify listings of other franchises.");
                }

                listing.Visible = visible;
                await dbContext.SaveChangesAsync();
                return ServiceOutput<object>.Success(null);

            }

            return ServiceOutput<object>.Error(HttpCode.NotFound,"The selected listing does not exist.");


        }

        public async Task <ServiceOutput<ReportResponseSubDTO>> ReportMisuse(Guid token_holder, Guid ListingId, Guid? CommentId, string Reason)
        {
            if (string.IsNullOrEmpty(Reason))
            {
                return ServiceOutput<ReportResponseSubDTO>.Error(HttpCode.BadRequest,"You need to provide a reason behind your report.");
            }

            Listing? listing = await dbSet.FindAsync(ListingId);

            if (listing == null)
            {
                return ServiceOutput<ReportResponseSubDTO>.Error(HttpCode.NotFound,"The selected listing does not exist.");
            }

            if (CommentId != null)
            {
                Comment? comment = await dbContext.Comments.FindAsync(CommentId);

                if (comment == null)
                {
                    return ServiceOutput<ReportResponseSubDTO>.Error(HttpCode.NotFound,"The selected comment does not exist.");
                }

                if (comment.ListingId != ListingId)
                {
                    return ServiceOutput<ReportResponseSubDTO>.Error(HttpCode.BadRequest,"The selected comment was not made on this listing.");
                }
            }

            Report? report = await dbContext.Reports.FirstOrDefaultAsync(r=>r.ReporterId==token_holder && r.ListingId==ListingId);

            if (report != null)
            {
                return ServiceOutput<ReportResponseSubDTO>.Error(HttpCode.Conflict,"You may only make one report per listing.");
            }

            Report new_report = new();
            new_report.ReporterId=token_holder;
            new_report.Reason=Reason;
            new_report.ListingId=ListingId;
            new_report.CommentId=CommentId;
            new_report.Expiry=DateTime.UtcNow.AddDays(7);
            await dbContext.Reports.AddAsync(new_report);
            await dbContext.SaveChangesAsync();

            return ServiceOutput<ReportResponseSubDTO>.Success(ReportResponseSubDTO.FromEntity(new_report),HttpCode.Created);

        }


        public async Task <ServiceOutput<DiscountResponseSubDTO>> SetDiscount(Guid token_holder, Guid ListingId, byte percentage, byte days_valid)
        {
            percentage = Math.Clamp(percentage,(byte)0,(byte)100);
            
            if(days_valid<3 || days_valid > 45)
            {
                return ServiceOutput<DiscountResponseSubDTO>.Error(HttpCode.BadRequest,"Only discounts with periods of 3 to 45 days will be considered.");
            }
            if(percentage<15)
            {
                return ServiceOutput<DiscountResponseSubDTO>.Error(HttpCode.BadRequest,"Only discounts of 15% or higher will be considered.");
            }
            Listing? listing = await dbSet.FindAsync(ListingId);
            if (listing == null)
            {
                return ServiceOutput<DiscountResponseSubDTO>.Error(HttpCode.NotFound,"The selected listing does not exist.");
            }
            if(! await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, listing.FranchiseId))
            {
                return ServiceOutput<DiscountResponseSubDTO>.Error(HttpCode.Forbidden,"You do not have the permission to set discounts for this listing.");
            }            
            Discount? discount = await dbContext.Discounts.FirstOrDefaultAsync(d=>d.ListingId==ListingId);
            if (discount != null)
            {
                return ServiceOutput<DiscountResponseSubDTO>.Error(HttpCode.Conflict,"You may not apply new discounts while there are active discounts present.");
            }

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {

                try
                {
                    Discount new_discount = new();
                    new_discount.ListingId=ListingId;
                    new_discount.Expiry=DateTime.UtcNow.AddDays(days_valid);
                    new_discount.PercentDiscount=percentage;
                    await dbContext.Discounts.AddAsync(new_discount);
                    await dbContext.SaveChangesAsync();
                    await recommender.RecommendListingToUsers(dbContext,new_discount);

                    await tx.CommitAsync();
                    return ServiceOutput<DiscountResponseSubDTO>.Success(DiscountResponseSubDTO.FromEntity(new_discount),HttpCode.Created);
                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<DiscountResponseSubDTO>.FromException(ex);
                }


            }

        }

        public async Task <ServiceOutput<AvailabilityResponseSubDTO>> SetAvailability(Guid token_holder, Guid ListingId, Guid FacilityId, bool add_remove)
        {
            Listing? listing = await dbSet.FindAsync(ListingId);
            Facility? facility = await dbContext.Facilities.FindAsync(FacilityId);
            if (listing == null || facility == null)
            {
                return ServiceOutput<AvailabilityResponseSubDTO>.Error(HttpCode.NotFound,"One or more resources needed for this operation do not exist.");
            }
            if (listing.FranchiseId != facility.FranchiseId)
            {
                return ServiceOutput<AvailabilityResponseSubDTO>.Error(HttpCode.Conflict,"The listing and facility are not owned by the same franchise.");    
            }
            if(!await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, listing.FranchiseId))
            {
                return ServiceOutput<AvailabilityResponseSubDTO>.Error(HttpCode.Forbidden,"You are not employed by this franchise.");
            }
            Available? available = await dbContext.ListingAvailable.FirstOrDefaultAsync(a=>a.ListingId==ListingId&& a.FacilityId==FacilityId);
            if (add_remove)
            {
                if (available == null)
                {
                    Available new_record = new();
                    new_record.FacilityId=FacilityId;
                    new_record.ListingId=ListingId;
                    await dbContext.ListingAvailable.AddAsync(new_record);
                    await dbContext.SaveChangesAsync();
                    available=new_record;
                }
                return ServiceOutput<AvailabilityResponseSubDTO>.Success(AvailabilityResponseSubDTO.FromEntity(available),HttpCode.Created);
            }
            else
            {
                if (available != null)
                {
                    dbContext.ListingAvailable.Remove(available);
                    await dbContext.SaveChangesAsync();
                }
                return ServiceOutput<AvailabilityResponseSubDTO>.Success(null,HttpCode.NoContent);
                
            }

        }

        public override async Task<ServiceOutput<ListingResponseDTO>> Post(Guid token_holder, ListingRequestDTO req)
        {
            Listing? lst = req.ToEntity();
            ProductListing? plst = req?.ProductListingExtension?.ToEntity();
            MedicalListing? mlst = req?.MedicalListingExtension?.ToEntity();
            AnimalListing? alst = req?.AnimalListingExtension?.ToEntity();

            if(lst!=null && ((lst.Type==ListingType.Product&&plst!=null)||(lst.Type==ListingType.Medical&&mlst!=null)||(lst.Type==ListingType.Pet&&alst!=null)))
            {

                using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        Franchise? franch = await dbContext.Franchises.FindAsync(req?.FranchiseId);
                        Guid? owner = franch?.OwnerId??null;

                        lst.AlbumId=await ImageService.CreateAlbum(owner,dbContext,1);

                        await dbSet.AddAsync(lst);
                        await dbContext.SaveChangesAsync();

                        switch (lst.Type)
                        {
                            case ListingType.Product : {if(plst!=null){plst.Id=lst.Id;await dbContext.ProductListings.AddAsync(plst);}break;}
                            case ListingType.Medical : {if(mlst!=null){mlst.Id=lst.Id;await dbContext.MedicalListings.AddAsync(mlst);}break;}
                            case ListingType.Pet : {if(alst!=null){alst.Id=lst.Id;await dbContext.AnimalListings.AddAsync(alst);}break;}
                            default : {break;}
                        }                       

                        await dbContext.SaveChangesAsync();

                        lst.ProductExtension=plst;
                        lst.AnimalExtension=alst;
                        lst.MedicalExtension=mlst;
                       
                        await tx.CommitAsync();
                        return ServiceOutput<ListingResponseDTO>.Success(ListingResponseDTO.FromEntity(lst),HttpCode.Created);
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<ListingResponseDTO>.FromException(ex);
                    
                    }

                    

                }

            }

            return ServiceOutput<ListingResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");

        }

        public override async Task<ServiceOutput<ListingResponseDTO>> Put(Guid token_holder, ListingRequestDTO req)
        {
            Listing? listing = await dbSet.Include(l=>l.ProductExtension).Include(l=>l.MedicalExtension).Include(l=>l.AnimalExtension).FirstOrDefaultAsync(l=>l.Id==req.Id);

            if (listing != null)
            {
                using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        listing.CurrentVersion=req.CurrentVersion;
                        listing.ListingName=req.Name;
                        listing.ListingDescription=req.Description;
                        listing.PriceMinor=req.PriceMinor;

                        if (listing.Type == ListingType.Product && listing.ProductExtension != null && req.ProductListingExtension != null)
                        {
                            listing.ProductExtension.PerListing=req.ProductListingExtension.PerListing;
                            listing.ProductExtension.CurrentVersion=req.ProductListingExtension.CurrentVersion;
                        }

                        await dbContext.SaveChangesAsync();
                        
                        await tx.CommitAsync();
                        return ServiceOutput<ListingResponseDTO>.Success(ListingResponseDTO.FromEntity(listing));
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<ListingResponseDTO>.FromException(ex);
                    }

                }
                
            }

            return ServiceOutput<ListingResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, ListingRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(!await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, resource.FranchiseId))
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You lack the permissions to post listings for this franchise.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, ListingRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(!await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, resource.FranchiseId))
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You lack the permissions to post listings for this franchise.");
            }
            Listing? listing = await dbSet.FindAsync(resource.Id);
            if (listing == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The selected listing does not exist.");
            }
            if (listing.Approved)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"An approved listing cannot be altered.");
            }
            if (listing.FranchiseId != resource.FranchiseId)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You may not alter the ownership of the listing.");
            }
            if (listing.Type != resource.Type)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You may not alter the type of the listing.");
            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            Listing? listing = await dbSet.FindAsync(resourceId);

            if (listing != null)
            {
                Account? account = await dbContext.Accounts.FindAsync(token_holder);

                if (account == null)
                {
                    return ServiceOutput<object>.Error(HttpCode.Unauthorized,"Invalid token.");
                }

                if(!(account.AccessLevel==Access.Admin) && !(account.AccessLevel==Access.BusinessAccount && await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, listing.FranchiseId)))
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You lack the permission to delete this listing.");   
                }

            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);

        }
       

    }

       
}
