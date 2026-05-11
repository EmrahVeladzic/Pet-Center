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
using Microsoft.Extensions.Logging;
using PetCenterModels.ModelUtils;


namespace PetCenterServices.Services
{
    public class AlbumIncludingService<TEntity,TSearch,TRequest,TResponse,TMedia,TBLOBRef,TMeta> : BaseCRUDService<TEntity,TSearch,TRequest,TResponse> where TEntity:AlbumIncludingTableEntity where TSearch: BaseSearchObject where TRequest: IBaseRequestDTO where TBLOBRef: BLOBReferencingEntity<TMeta> where TMedia:IBLOBReferencingDTO<TBLOBRef,TMedia,TMeta>  where TResponse : IAlbumCarryingDTO<TEntity,TResponse,TMedia,TBLOBRef,TMeta> where TMeta : IMetadataOutput
    {
        protected FilePurpose Purpose {get; set;}

        public AlbumIncludingService(PetCenterDBContext ctx, ILoggerFactory _logger) : base(ctx,_logger)
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

        public void AttachTokensIfNeeded(TResponse response, FileScope fileScope)
        {
            FileScope scope = fileScope;

            if (response.Locked)
            {
                scope = FileScope.ReadOnly;
            }

            if(scope==FileScope.Write){
                response.MediaCreationToken=Crypto.GenerateFileToken("",Purpose,scope,response.AlbumId);
            }
            foreach(TMedia media in response.Media)
            {
                media.Token=Crypto.GenerateFileToken(media.Hash,Purpose,scope,response.AlbumId);
            }
        }

        public override async Task<ServiceOutput<List<TResponse>>> Get(Guid token_holder, TSearch search)
        {
            IQueryable<TEntity> query = await Filter(token_holder,search);
            List<TEntity> entities = await query.Skip(search.Page*search.PageSize).Take(search.PageSize).ToListAsync();
            List<TResponse>responses = entities.Select(e=>TResponse.FromEntity(e)!).ToList();
            if (search.FileRW != FileScope.Invalid)
            {
                foreach(TResponse response in responses)
                {
                   AttachTokensIfNeeded(response,search.FileRW);
                    
                }
            }

            
            return  ServiceOutput<List<TResponse>>.Success(responses);
        }

        public override async Task<ServiceOutput<TResponse>> GetById(Guid token_holder, Guid id, Access authorization_level, FileScope file_scope = FileScope.Invalid)
        {
            TEntity? entity = await WithAlbum().FirstOrDefaultAsync(e=>e.Id==id);

            if (entity != null) 
            {      
                TResponse? output = TResponse.FromEntity(entity);

                if(output!=null && output.Media.Count > 0 && file_scope!=FileScope.Invalid)
                {
                    AttachTokensIfNeeded(output,file_scope);
                }

                return  ServiceOutput<TResponse>.Success(output);                  
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

                await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            ent.AlbumId = await ImageService.CreateAlbum(null,dbContext,ent.AlbumCapacity);
                            await dbSet.AddAsync(ent);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                            return ServiceOutput<TResponse>.Success(TResponse.FromEntity(ent,Crypto.GenerateFileToken("",Purpose,FileScope.Write,ent.AlbumId)),HttpCode.Created);
                        }
                        catch(Exception ex)
                        {
                            await tx.RollbackAsync();
                            return ServiceOutput<TResponse>.FromException(ex,logger);
                        }
                    }

                   
                }     

            }
           
            return ServiceOutput<TResponse>.Error(HttpCode.InternalError, "Internal server error.");

        }



    }
}
