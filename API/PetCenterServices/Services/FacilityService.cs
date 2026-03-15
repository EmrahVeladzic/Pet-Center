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


namespace PetCenterServices.Services
{
    public class FacilityService : BaseCRUDService<Facility,FacilitySearchObject,FacilityDTO,FacilityDTO>, IFacilityService    
    {

        public FacilityService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Facilities;
        }

        protected override Task<IQueryable<Facility>> Filter(Guid token_holder, FacilitySearchObject search)
        {
            IQueryable<Facility> output = dbSet.Where(f=>f.FranchiseId==search.FranchiseId);
            if (search.ServesListing != null)
            {
                output = output.Where(f=>dbContext.ListingAvailable.Any(a=>a.ListingId == search.ServesListing && a.FacilityId == f.Id));
            }
            
            return Task.FromResult<IQueryable<Facility>>(output);
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, FacilityDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }

            Franchise? franch = await dbContext.Franchises.FindAsync(resource.OwningFranchise);
            if (franch == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"Could not find franchise.");
            }
            if (franch.OwnerId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this franchise.");
            }
            Facility? fac = await dbSet.FirstOrDefaultAsync(f=>f.City.ToLower()==resource.City.ToLower()&&f.Street.ToLower()==resource.Street.ToLower()&&f.FranchiseId==resource.OwningFranchise);
            if (fac != null)
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"A facility with these parameters already exists.");
            }

            return ServiceOutput<object>.Success(null);
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, FacilityDTO resource)
        {
          if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }

            Franchise? franch = await dbContext.Franchises.FindAsync(resource.OwningFranchise);
            if (franch == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"Could not find franchise.");
            }
            if (franch.OwnerId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this franchise.");
            }
            Facility? fac = await dbSet.FirstOrDefaultAsync(f=>f.City.ToLower()==resource.City.ToLower()&&f.Street.ToLower()==resource.Street.ToLower()&&f.FranchiseId==resource.OwningFranchise&& f.Id!=resource.Id);
            if (fac != null)
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"A facility with these parameters already exists.");
            }
              fac = await dbSet.FindAsync(resource.Id);
            if (fac == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"Could not find facility.");    
            }
            if (fac.FranchiseId != resource.OwningFranchise)
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"You may not alter the owning franchise of a facility.");
            }
            return ServiceOutput<object>.Success(null);
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            Facility? fac = await dbSet.Include(f=>f.OwningFranchise).FirstOrDefaultAsync(f=>f.Id==resourceId);
            if (fac != null)
            {
                if (fac.OwningFranchise == null)
                {
                    return ServiceOutput<object>.Error(HttpCode.InternalError,"Internal server error.");
                }
                if(fac.OwningFranchise.OwnerId != token_holder)
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You lack the permission to delete this facility.");
                }            
            }           
            
            return ServiceOutput<object>.Success(null,HttpCode.OK);
        }

    }
}
