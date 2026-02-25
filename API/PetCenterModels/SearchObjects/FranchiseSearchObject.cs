using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.SearchObjects
{
    public class FranchiseSearchObject : BaseSearchObject
    {
        public Guid? RelatedUser {get; set;} = null;

    }
}
