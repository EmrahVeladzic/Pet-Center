using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public enum OrderingMethod : byte
    {
        ID = 0,
        PriceDescending = 1,
        PriceAscending = 2,
        PostedDescending = 3,
        PostedAscending = 4
    }

    public class ListingSearchObject:BaseSearchObject
    {
    
        public ListingType Type {get; set;} = ListingType.Generic;

        public Guid RelevantId {get; set;} = Guid.Empty;

        public OrderingMethod OrderBy {get; set;} = OrderingMethod.ID;

        public bool ShowApprovedAndPending {get; set;} = false;

        public Guid KindSpecific {get; set;} = Guid.Empty;

        public Guid BreedSpecific {get; set;} = Guid.Empty;

        public bool SexSpecific {get; set;}

        public AnimalScale ScaleSpecific {get; set;} 


        [JsonIgnore]
        public override int PageSize =>10;

    }
}
