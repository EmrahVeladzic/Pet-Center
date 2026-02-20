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
        public Guid KindId { get; set; } = Guid.Empty;
    }
}
