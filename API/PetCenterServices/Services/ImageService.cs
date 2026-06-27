using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.ModelUtils;
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
    public class ImageService : BaseBLOBService<Image,ImageBLOB,ImageMetadata,ImageDTO>, IImageService
    {
      
        public ImageService(PetCenterDBContext ctx,ILoggerFactory _logger):base(ctx,_logger)
        {            
            dbSetMeta = dbContext.Images;
            dbSetBLOB = dbContext.ImageBLOBs;
            Purpose=FilePurpose.Image;
        }


        public override async Task<ServiceOutput<object>> CheckScope(Guid token_holder, Guid album_id, FileScope expected, string origin, string? hash)
        {
            Account? acc = await dbContext.Accounts.FindAsync(token_holder);

            if(hash!=null && !await dbSetMeta.AnyAsync(m => m.AlbumId == album_id && m.BLOBId == hash))
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"No image with the provided hash could be found in the album.");
            }

            if (acc == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"Account does not exist.");
            }

            if (origin == "BREED")
            {
                Breed? breed = await dbContext.AnimalBreeds.Include(b=>b.Album).Where(b=>b.AlbumId==album_id).FirstOrDefaultAsync();
                if (breed == null||breed.Album==null)
                {
                    return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested entity was unable to be located.");
                }

                if (acc.AccessLevel == Access.Admin || acc.AccessLevel == Access.Owner)
                {
                    return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                }
                else if (acc.AccessLevel == Access.User)
                {
                    if(breed.Album.Reserved>0 && expected!=FileScope.Write){

                        return ServiceOutput<object>.Success(null,HttpCode.NoContent);

                    }
                }

            }
            else if (origin == "FORM")
            {
                Form? frm = await dbContext.Forms.Include(f=>f.Album).Where(f=>f.AlbumId==album_id).FirstOrDefaultAsync();
                if (frm == null||frm.Album==null)
                {
                    return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested entity was unable to be located.");
                }

                if (acc.AccessLevel == Access.Admin || acc.AccessLevel == Access.Owner)
                {
                    if(frm.Album.Reserved>0 && expected!=FileScope.Write){

                        return ServiceOutput<object>.Success(null,HttpCode.NoContent);

                    }
                }
                else if (acc.AccessLevel == Access.BusinessAccount)
                {
                    if(frm.UserId==token_holder){

                        return ServiceOutput<object>.Success(null,HttpCode.NoContent);

                    }
                }
                
            }
            else if(origin == "LISTING")
            {
                Listing? lst = await dbContext.Listings.Include(l=>l.Album).Where(l=>l.AlbumId==album_id).FirstOrDefaultAsync();
                if (lst == null||lst.Album==null)
                {
                    return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested entity was unable to be located.");
                }

                if (acc.AccessLevel == Access.Admin || acc.AccessLevel == Access.Owner)
                {
                    if(lst.Album.Reserved>0 && expected!=FileScope.Write){

                        return ServiceOutput<object>.Success(null,HttpCode.NoContent);

                    }
                }
                else if (acc.AccessLevel == Access.BusinessAccount)
                {
                    if(await FranchiseService.IsEmployeeOfFranchise(dbContext,token_holder,lst.FranchiseId)){

                        return ServiceOutput<object>.Success(null,HttpCode.NoContent);

                    }
                }
                else
                {
                    if(lst.Visible&& lst.Status==EvaluationStatus.Approved && lst.Album.Reserved>0 && expected!=FileScope.Write){

                        return ServiceOutput<object>.Success(null,HttpCode.NoContent);

                    }
                }



            }


            return ServiceOutput<object>.Error(HttpCode.Unauthorized,"You lack the authorization to interact with this image.");

        }
        

    

       
    }
}
