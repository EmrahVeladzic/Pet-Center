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
    public class AlbumIncludingService<TEntity,TSearch,TRequest,TResponse> : BaseCRUDService<TEntity,TSearch,TRequest,TResponse> where TEntity:AlbumIncludingTableEntity where TSearch: BaseSearchObject where TRequest: IBaseRequestDTO where TResponse : IAlbumCarryingDTO<TEntity,TResponse>
    {
        public AlbumIncludingService(PetCenterDBContext ctx) : base(ctx)
        {
            
        }
      
        protected IQueryable<TEntity> WithAlbum()
        {
           return dbSet.Include(e=>e.Album).ThenInclude(a=>a!.Images);
        }

        protected override Task<IQueryable<TEntity>> Filter(Guid token_holder, TSearch search)
        {           
            return Task.FromResult<IQueryable<TEntity>>(WithAlbum().OrderBy(o=>o.Id));
        }


        public override async Task<ServiceOutput<TResponse>> GetById(Guid token_holder, Guid id)
        {
            TEntity? entity = await WithAlbum().FirstOrDefaultAsync(e=>e.Id==id);

            if (entity != null) 
            {      
                return  ServiceOutput<TResponse>.Success(TResponse.FromEntity(entity));                  
            }
            
            return ServiceOutput<TResponse>.Error(HttpCode.NotFound, "No resource with this ID exists.");
            
        }

        public override async Task<ServiceOutput<TResponse>> Post(Guid token_holder,TRequest req)
        {
            bool valid = req.Validate();
            if (!valid)
            {
                return ServiceOutput<TResponse>.Error(HttpCode.BadRequest,"Invalid request.");
            }

            if(req is ISerializableRequestDTO<TEntity> serializable)
            {
                TEntity? ent = serializable.ToEntity();

                if(ent!=null){

                    using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            ent.AlbumId = await ImageService.CreateAlbum(token_holder,dbContext,ent.AlbumCapacity);
                            await dbSet.AddAsync(ent);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                            return ServiceOutput<TResponse>.Success(TResponse.FromEntity(ent),HttpCode.Created);
                        }
                        catch
                        {
                            await tx.RollbackAsync();
                        }
                    }

                   
                }     

            }
           
            return ServiceOutput<TResponse>.Error(HttpCode.InternalError, "Internal server error.");

        }



    }
}
