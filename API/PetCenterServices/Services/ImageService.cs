using Microsoft.EntityFrameworkCore;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
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

        public override async Task<ServiceOutput<object>> Delete(Guid? token_holder,Guid id)
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
                await dbContext.SaveChangesAsync();
            }

            return ServiceOutput<object>.Success(default,HttpCode.NoContent);

        }

        public override async Task<ServiceOutput<ImageDTO>> Put(Guid? token_holder,ImageDTO image)
        {
            Image? img = await dbContext.Images.FindAsync(image.Id);

            if (img != null)
            {
                Image? newImage = image.ToEntity();

                if (newImage != null)
                {
                    img.Data=newImage.Data;
                    img.Width=newImage.Width;
                    img.Height=newImage.Height;

                    image.AlbumInsertId = img.AlbumId;                 
                        
                    await dbContext.SaveChangesAsync();

                    return ServiceOutput<ImageDTO>.Success(image);

                }

                return ServiceOutput<ImageDTO>.Error(HttpCode.BadRequest,"Invalid image data.");

               
            }

            return ServiceOutput<ImageDTO>.Error(HttpCode.NotFound,"No image with this ID exists.");
        }

        public override async Task<ServiceOutput<ImageDTO>> Post(Guid? token_holder,ImageDTO img)
        {
            Album? album = await dbContext.Albums.FindAsync(img.AlbumInsertId);

            if (album != null )
            {

                if (album.Reserved < album.Capacity)
                {                   

                    Image? newImage = img.ToEntity();

                    if (newImage != null)
                    {
                        album.Reserved++;
                        await dbContext.Images.AddAsync(newImage);
                        await dbContext.SaveChangesAsync();
                        img.Id=newImage.Id;
                    
                        return ServiceOutput<ImageDTO>.Success(img,HttpCode.Created);
                    }

                    return ServiceOutput<ImageDTO>.Error(HttpCode.BadRequest,"Invalid image data.");
                }

                return ServiceOutput<ImageDTO>.Error(HttpCode.Forbidden,"The selected album is full and cannot accept a new image.");

            }

            return ServiceOutput<ImageDTO>.Error(HttpCode.NotFound,"No album with this ID exists.");

        }


        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid? token_holder, ImageDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failure.");
            }
            if(token_holder!=null){
                Album? album = await dbContext.Albums.FindAsync(resource.AlbumInsertId);
                if (album != null)
                {
                    if (album.PosterID == token_holder)
                    {
                        if (album.Reserved < album.Capacity)
                        {
                            if (resource.Id == null)
                            {
                                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                            }
                            return ServiceOutput<object>.Error(HttpCode.BadRequest,"Image ID was provided, but should be NULL."); 
                        }                    
                        return ServiceOutput<object>.Error(HttpCode.Conflict,"Album is already full.");
                    }
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to the owner of this album.");
                }
                return ServiceOutput<object>.Error(HttpCode.NotFound,"Attempted to insert image into a non-existant album.");
            }
            return ServiceOutput<object>.Error(HttpCode.Unauthorized,"This action requires authorization");
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid? token_holder, ImageDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failure.");
            }
            if(token_holder!=null){
                Album? album = await dbContext.Albums.FindAsync(resource.AlbumInsertId);
                Image? image = await dbContext.Images.FindAsync(resource.Id);
                if(album!=null && image != null)
                {
                    if (album.PosterID == token_holder)
                    {
                        if (image.AlbumId == album.Id)
                        {
                            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                        }
                        return ServiceOutput<object>.Error(HttpCode.BadRequest,"The requested image does not belong in this album.");
                    }
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to the owner of this album.");
                }
                return ServiceOutput<object>.Error(HttpCode.NotFound,"One or more requested resources do not exist.");  
            }
            return ServiceOutput<object>.Error(HttpCode.Unauthorized,"This action requires authorization");
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid? token_holder, Guid resourceId)
        {
            if (token_holder != null)
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
                                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                            }
                            return ServiceOutput<object>.Error(HttpCode.BadRequest,"The requested image does not belong in this album.");
                        }
                        return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to the owner of this album.");
                    }
                    return ServiceOutput<object>.Error(HttpCode.InternalError,"Unexpected NULL when trying to find the image album.");
                }
                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
            }
            return ServiceOutput<object>.Error(HttpCode.Unauthorized,"This action requires authorization");
        }


    }
}
