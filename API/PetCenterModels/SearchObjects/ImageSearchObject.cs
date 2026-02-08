using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class ImageSearchObject: BaseSearchObject
    {      
        public override int PageSize => (int)Album.MaxCapacity;
    }
}
