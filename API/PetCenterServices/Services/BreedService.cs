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
    public class BreedService : AlbumIncludingService<Breed,BreedSearchObject,BreedDTO,BreedDTO>, IBreedService    
    {
        private readonly IRecommenderSystem recommender;

        public BreedService(PetCenterDBContext ctx, IRecommenderSystem rec) : base(ctx)
        {
            dbSet = ctx.AnimalBreeds;
            recommender = rec;
        }

        protected override void Touch()
        {
            StaticDataVersionHolder.BreedVersion = Guid.NewGuid();
        }

        protected override async Task<IQueryable<Breed>> Filter(Guid token_holder, BreedSearchObject search)
        {
            
            IQueryable<Breed> query = dbSet.OrderBy(b=>b.Id);
            User? usr = await dbContext.Users.FindAsync(token_holder);

            if(search.AuthoritySpecifier == Access.Admin && search.Incomplete)
            {
                query = query.Where(b=>b.Album.Reserved==0);
            }

            if(search.AuthoritySpecifier == Access.User && search.AdoptionPurposes && usr!=null)
            {
                
                query = WithAlbum();
                query = query.Where(b=> b.Album.Reserved>0);               
                query = query.Where(b =>
                dbContext.AnimalListings.Any(al =>
                al.Animal.AnimalBreed.Id == b.Id && b.KindId==search.KindId &&
                al.Base.Visible &&
                al.Base.Type == ListingType.Pet));
                query=await recommender.GetMostCompatibleBreeds(dbContext,query,usr);


            }

            return query;
            
            
        }

        public override async Task<ServiceOutput<List<BreedDTO>>> Get(Guid token_holder, BreedSearchObject search)
        {
            if(search.AdoptionPurposes && search.AuthoritySpecifier == Access.User)
            {
                return await base.Get(token_holder, search);
            }
            else
            {
                IQueryable<Breed> breeds = await Filter(token_holder,search);
                List<Breed> output = await breeds.ToListAsync();

                return ServiceOutput<List<BreedDTO>>.Success(output.Select(b=>BreedDTO.FromEntity(b)!).ToList());
            }
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, BreedDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }

            if(await dbContext.AnimalKinds.AnyAsync(k => k.Id == resource.KindId))
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The specified kind does not exist.");
            }
            
            if(await dbSet.FirstOrDefaultAsync(b =>b.Title.ToLower()==resource.Title.ToLower() && b.KindId == resource.KindId)!=null){
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A breed with the same kind and title already exists.");
            }

            return ServiceOutput<object>.Success(null);
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, BreedDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }

            if(await dbContext.AnimalKinds.AnyAsync(k => k.Id == resource.KindId))
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The specified kind does not exist.");
            }
            
            if(await dbSet.FirstOrDefaultAsync(b => EF.Functions.Like(b.Title,resource.Title) && b.KindId == resource.KindId && b.Id!=resource.Id)!=null){
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A breed with the same title already exists.");
            }

            if(!await dbSet.AnyAsync(b=>b.Id==resource.Id&&b.KindId==resource.KindId)){
                return ServiceOutput<object>.Error(HttpCode.Conflict,"You cannot change a breed's kind.");
            }

            if(!await dbSet.AnyAsync(b=>b.Id==resource.Id&&b.AlbumId==resource.AlbumId)){
                return ServiceOutput<object>.Error(HttpCode.Conflict,"You cannot change a breed's album.");
            }


            return ServiceOutput<object>.Success(null);
        }

        public override Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            return Task.FromResult(ServiceOutput<object>.Success(null));
        }

    }

       
}
