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
using System.Formats.Tar;
using PetCenterModels.ModelUtils;


namespace PetCenterServices.Services
{
    public class BaseBLOBService<TEntity,TBLOB,TMeta,TDTO> : IBaseBLOBService<TEntity,TBLOB,TMeta,TDTO> where TEntity : BLOBReferencingEntity<TMeta>, new() where TBLOB: BaseBLOBEntity<TMeta>, IBaseBlobEntity<TMeta,TBLOB> where TMeta : IMetadataOutput, new() where TDTO: IBLOBReferencingDTO<TEntity,TDTO,TMeta>
    {
        protected PetCenterDBContext dbContext;
        protected DbSet<TEntity> dbSetMeta;
        protected DbSet<TBLOB> dbSetBLOB;

        protected FilePurpose Purpose;

        protected ILogger logger;

        public BaseBLOBService(PetCenterDBContext ctx,ILoggerFactory _logger)
        {
            dbContext = ctx;
            logger=_logger.CreateLogger(GetType());
            dbSetMeta = dbContext.Set<TEntity>();
            dbSetBLOB = dbContext.Set<TBLOB>();
        }

        public virtual async Task<ServiceOutput<TDTO>> Upload(Guid token_holder, Guid insert_album, byte[] data)
        {
            Album? album = await dbContext.Albums.FindAsync(insert_album);

            if (album == null)
            {
                return ServiceOutput<TDTO>.Error(HttpCode.NotFound,"The selected album does not exist.");
            }

            if (album.Locked)
            {
                return ServiceOutput<TDTO>.Error(HttpCode.Forbidden,"The selected album is locked and its contents cannot be modified.");
            }

            if (album.Reserved >= album.Capacity)
            {
                return ServiceOutput<TDTO>.Error(HttpCode.Forbidden,"The selected album is full.");
            }

            TBLOB? blob = TBLOB.TryCreateFromOctet(data,out TMeta metadata);
            

            if (blob != null)
            {
                bool present = await dbSetBLOB.AnyAsync(b=>b.Id==blob.Id);

                await using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync()){

                    try
                    {
                        if (!present)
                        {
                            await dbSetBLOB.AddAsync(blob);
                           
                        }
                        
                        TEntity entity = new();
                        entity.BLOBId=blob.Id;
                        entity.LoadMetadata(metadata);
                        entity.AlbumId=insert_album;
                        album.Reserved++;

                        await dbSetMeta.AddAsync(entity);

                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();

                        return ServiceOutput<TDTO>.Success(TDTO.FromEntity(entity,Crypto.GenerateFileToken(entity.BLOBId,Purpose,FileScope.Write,insert_album)));

                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<TDTO>.FromException(ex,logger);
                    }

                }
            }

            return ServiceOutput<TDTO>.Error(HttpCode.BadRequest,"File upload failed. The file may be corrupted.");

        }

        public virtual async Task<ServiceOutput<byte[]>> Download(Guid token_holder, string hash)
        {
            TBLOB? blob = await dbSetBLOB.FindAsync(hash);
            if (blob != null)
            {
                return ServiceOutput<byte[]>.Success(blob.Data);
            }
            else
            {
                return ServiceOutput<byte[]>.Error(HttpCode.NotFound,"The requested data does not exist.");
            }
        }

        public virtual async Task<ServiceOutput<object>> Delete(Guid token_holder,string hash, Guid album_id)
        {
            TEntity? entity = await dbSetMeta.Include(e=>e.OwningAlbum).FirstOrDefaultAsync(e=>e.BLOBId==hash && e.AlbumId==album_id);

            if (entity != null)
            {
                if (entity.OwningAlbum == null)
                {
                    return ServiceOutput<object>.Error(HttpCode.InternalError,"Internal server error.");
                }
                if (entity.OwningAlbum.Locked)
                {                    
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"The selected album is locked and its contents cannot be modified.");
                }

                await using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {

                    try
                    {                        
                        await entity.StageDeletion<TEntity>(dbContext,dbSetMeta);                        
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<object>.FromException(ex,logger);
                    }


                }


            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

        public static async Task<Guid> CreateAlbum(Guid? token_holder,PetCenterDBContext ctx, byte cap)
        {
            DBUtils.EnsureInTransaction(ctx);
            Album alb = new(cap);
            alb.PosterID = token_holder;
            await ctx.Albums.AddAsync(alb);
            await ctx.SaveChangesAsync();
            return alb.Id;
        }
       
    }
}
