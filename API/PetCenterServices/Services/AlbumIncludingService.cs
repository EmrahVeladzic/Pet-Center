using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
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

        protected override IQueryable<TEntity> Filter(TSearch search)
        {
            return WithAlbum().OrderBy(o=>o.Id);
        }


        public override async Task<ServiceOutput<TResponse>> GetById(Guid id)
        {
            TEntity? entity = await WithAlbum().FirstOrDefaultAsync(e=>e.Id==id);

            if (entity != null) 
            {      
                return  ServiceOutput<TResponse>.Success(TResponse.FromEntity(entity));                  
            }
            
            return ServiceOutput<TResponse>.Error(HttpCode.NotFound, "No resource with this ID exists.");
            
        }




    }
}
