using Microsoft.EntityFrameworkCore;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
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


        public async Task<Image?> GetById(Guid id)
        {
            return await dbContext.Images.FindAsync(id);
        }

        public async Task<List<Image>> Get(BaseSearchObject src)
        {
            return await dbContext.Images.Skip(src.Page*50).Take(50).ToListAsync();
        }

        public async Task Delete(Guid id)
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

        }

        public async Task Put(Image image)
        {
            Image? img = await dbContext.Images.FindAsync(image.Id);

            if (img != null)
            {

                dbContext.Images.Entry(img).CurrentValues.SetValues(image);
                await dbContext.SaveChangesAsync();
            }

        }

        public async Task Post(Image img)
        {
            Album? album = await dbContext.Albums.FindAsync(img.AlbumId);

            if (album != null && album.Reserved<album.Capacity)
            {
                album.Reserved++;
                await dbContext.Images.AddAsync(img);
                await dbContext.SaveChangesAsync();

            }

        }

        public async Task UploadImage(ImageDTO dto)
        {
            Image img = new(dto);

            await Post(img);

        }

        public async Task<List<ImageDTO>> GetAlbumImages(Guid AlbumID)
        {
                return await dbContext.Images
            .Where(i => i.AlbumId == AlbumID)
            .Select(img => new ImageDTO(img))
            .ToListAsync();
        }
    }
}
