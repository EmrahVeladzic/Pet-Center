using Microsoft.EntityFrameworkCore;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Services
{
    public class ImageService : IImageService
    {
        protected PetCenterDBContext dbContext;

        public ImageService(PetCenterDBContext ctx)
        {
             dbContext = ctx;
        }


        public async Task<ServiceOutput<ImageDTO>> GetById(Guid id)
        {            
            Image? img = await dbContext.Images.FindAsync(id);
            if(img == null){
            
                return ServiceOutput<ImageDTO>.Error(HttpCode.NotFound,"No image with this ID exists.");
            
            }
            return ServiceOutput<ImageDTO>.Success(new ImageDTO(img));           
        }

        public async Task<ServiceOutput<List<ImageDTO>>> Get(BaseSearchObject src)
        {
            return ServiceOutput<List<ImageDTO>>.Success(await dbContext.Images.OrderBy(i=>i.Id).Skip(src.Page*src.PageSize).Take(src.PageSize).Select(img => new ImageDTO(img)).ToListAsync());
        }

        public async Task<ServiceOutput<object>> Delete(Guid id)
        {
            Image? img = await dbContext.Images.FindAsync(id);

            if (img != null)
            {
                Album? album = await dbContext.Albums.FindAsync(img.AlbumId);

                if (album != null && album.Reserved>0)
                {
                    album.Reserved--;                       

                    dbContext.Images.Remove(img);
                    await dbContext.SaveChangesAsync();

                }

            }

            return ServiceOutput<object>.Success(default,HttpCode.NoContent);

        }

        public async Task<ServiceOutput<ImageDTO>> Put(ImageDTO image)
        {
            Image? img = await dbContext.Images.FindAsync(image.ImageId);

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

        public async Task<ServiceOutput<ImageDTO>> Post(ImageDTO img)
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
                        img.ImageId=newImage.Id;
                    
                        return ServiceOutput<ImageDTO>.Success(img,HttpCode.Created);
                    }

                    return ServiceOutput<ImageDTO>.Error(HttpCode.BadRequest,"Invalid image data.");
                }

                return ServiceOutput<ImageDTO>.Error(HttpCode.Forbidden,"The selected album is full and cannot accept a new image.");

            }

            return ServiceOutput<ImageDTO>.Error(HttpCode.NotFound,"No album with this ID exists.");

        }   

    }
}
