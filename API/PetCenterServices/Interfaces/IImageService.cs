using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Interfaces
{
    public interface IImageService : IBaseCRUDService<Image,BaseSearchObject>
    {
       
        public Task UploadImage(ImageDTO req);        


    }
}
