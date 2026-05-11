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

        

    

       
    }
}
