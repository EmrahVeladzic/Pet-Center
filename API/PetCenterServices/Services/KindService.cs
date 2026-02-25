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
    public class KindService : BaseCRUDService<Kind,KindSearchObject,KindDTO,KindDTO>, IKindService    
    {

        public KindService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.AnimalKinds;
        }

        protected override Task<IQueryable<Kind>> Filter(Guid token_holder, KindSearchObject search)
        {
            IQueryable<Kind> query = dbSet.Include(k=>k.Breeds).OrderBy(k=>k.Id);
            if (search.AuthoritySpecifier == Access.User && search.AdoptionPurposes)
            {
                query = query.Where(k =>
                dbContext.AnimalListings.Any(al =>
                al.Animal.AnimalBreed.KindId == k.Id &&
                al.Base.Visible &&
                al.Base.Type == ListingType.Pet));
            }
            return Task.FromResult(query);
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, KindDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(k=>k.Title.ToLowerInvariant()==resource.Title.ToLowerInvariant()))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A kind with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, KindDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(k=>k.Title.ToLowerInvariant()==resource.Title.ToLowerInvariant()&& k.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A kind with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
          
        }

        public override  Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {           
            
            return Task.FromResult(ServiceOutput<object>.Success(null,HttpCode.OK));
        }

    }
}
