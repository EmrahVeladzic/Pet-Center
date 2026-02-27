using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class IndividualSearchObject : BaseSearchObject
    {
        public Guid? from_franchise {get; set;} = null;

        [JsonIgnore]
        public override int PageSize {get;} = 50;
    }
}
