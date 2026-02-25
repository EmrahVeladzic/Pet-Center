using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.SearchObjects
{
    public class FacilitySearchObject : BaseSearchObject
    {
        
        public Guid FranchiseId {get; set;} = Guid.Empty;

        public Guid? ServesListing {get; set;} = null;
    }
}
