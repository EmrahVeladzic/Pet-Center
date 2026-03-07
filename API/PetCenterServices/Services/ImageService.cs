using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Services
{
    public class ImageService : BaseCRUDService<Image,ImageSearchObject,ImageDTO,ImageDTO>, IImageService
    {
        public ImageService(PetCenterDBContext ctx) : base(ctx)
        {            
            dbSet = ctx.Images;
        }

        public override async Task<ServiceOutput<object>> Delete(Guid token_holder,Guid id)
        {        
            Image? img = await dbContext.Images.FindAsync(id);

            if (img != null)
            {
                Album? album = await dbContext.Albums.FindAsync(img.AlbumId);

                if (album != null && album.Reserved>0)
                {
                    album.Reserved--;                      
                }

                dbContext.Images.Remove(img);

                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<object>.FromException(ex);
                    }
                }


            }

            return ServiceOutput<object>.Success(default,HttpCode.NoContent);

        }

        public override async Task<ServiceOutput<ImageDTO>> Post(Guid token_holder,ImageDTO img)
        {
            ServiceOutput<ImageDTO> output;
            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    output = await UploadImage(token_holder,img,dbContext);
                    await tx.CommitAsync();
                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    output = ServiceOutput<ImageDTO>.FromException(ex);

                }
            }

            return output;
        }


        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, ImageDTO resource)
        {
            return await EvaluateUploadAttempt(token_holder, resource, dbContext);
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
                                      
            Image? image = await dbContext.Images.FindAsync(resourceId);
            if (image != null)
            {
                Album? album = await dbContext.Albums.FindAsync(image.AlbumId);
                if (album != null)
                {
                    if (album.PosterID == token_holder)
                    {
                        if (image.AlbumId == album.Id)
                        {
                            if (!album.Locked)
                            {                                  
                                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                            }
                            return ServiceOutput<object>.Error(HttpCode.BadRequest,"The requested album is locked and its contents cannot be altered.");
                        }
                        return ServiceOutput<object>.Error(HttpCode.BadRequest,"The requested image does not belong in this album.");
                    }
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to the owner of this album.");
                }
                return ServiceOutput<object>.Error(HttpCode.InternalError,"Unexpected NULL when trying to find the image album.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        
        }



        public static async Task<ServiceOutput<object>> EvaluateUploadAttempt(Guid token_holder, ImageDTO img, PetCenterDBContext ctx)
        {

            if (!img.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failure.");
            }

            
            Album? album = await ctx.Albums.FindAsync(img.AlbumInsertId);
            if (album != null)
            {
                if (album.PosterID == token_holder)
                {
                    if (album.Reserved < album.Capacity)
                    {
                        if (img.Id == null)
                        {
                            if (!album.Locked)
                            {
                                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                            }
                            return ServiceOutput<object>.Error(HttpCode.BadRequest,"The requested album is locked and its contents cannot be altered.");
                        }
                        return ServiceOutput<object>.Error(HttpCode.BadRequest,"Image ID was provided, but should be NULL at this point."); 
                    }                    
                    return ServiceOutput<object>.Error(HttpCode.Conflict,"Album is already full.");
                }
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to the owner of this album.");
            }
            return ServiceOutput<object>.Error(HttpCode.NotFound,"Attempted to insert image into a non-existent album.");
            
        }

        public static async Task<ServiceOutput<ImageDTO>> UploadImage(Guid token_holder,ImageDTO img, PetCenterDBContext ctx)
        {
            ServiceOutput<object> evaluation = await EvaluateUploadAttempt(token_holder, img, ctx);
            if (!ServiceOutput<object>.IsSuccess(evaluation))
            {
                return ServiceOutput<ImageDTO>.Error(evaluation.Code,evaluation.ErrorMessage ?? "Unable to upload image.");
            }

            Album? album = await ctx.Albums.FindAsync(img.AlbumInsertId);

            if (album != null )
            {                                 

                Image? newImage = img.ToEntity();

                if (newImage != null)
                {                   
                    album.Reserved++;
                    await ctx.Images.AddAsync(newImage);
                    await ctx.SaveChangesAsync();
                    img.Id=newImage.Id;
                    
                    return ServiceOutput<ImageDTO>.Success(ImageDTO.FromEntity(newImage),HttpCode.Created);
                }

                return ServiceOutput<ImageDTO>.Error(HttpCode.BadRequest,"Invalid image data.");
               

            }

            return ServiceOutput<ImageDTO>.Error(HttpCode.NotFound,"No album with this ID exists.");

        }


        public static async Task<Guid> CreateAlbum(Guid token_holder,PetCenterDBContext ctx, byte cap)
        {
            Album alb = new(cap);
            alb.PosterID = (Guid)token_holder;
            await ctx.Albums.AddAsync(alb);
            await ctx.SaveChangesAsync();
            return alb.Id;
        }

        public static async Task ClearAlbum(Guid token_holder, PetCenterDBContext ctx, Guid album_id)
        {
            Album? alb = await ctx.Albums.FindAsync(album_id);
            if(alb==null || alb.PosterID!=token_holder || alb.Locked){return;}
            await alb.StageDeletion<Album>(ctx,ctx.Albums);
            await ctx.SaveChangesAsync();
        }    

       
    }
}
