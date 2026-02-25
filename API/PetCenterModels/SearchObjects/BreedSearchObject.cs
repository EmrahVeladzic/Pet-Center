using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class BreedSearchObject : BaseSearchObject
    {
        public bool AdoptionPurposes {get; set;} = false;

        public bool Incomplete {get; set;} = false;

        public Guid? KindId { get; set; } =null;

        [JsonIgnore]
        public override int PageSize {get;} = 25;
    }
}
