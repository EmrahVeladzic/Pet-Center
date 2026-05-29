using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class FormSearchObject : BaseSearchObject
    {
        [JsonIgnore]
        [ReadOnly(true)]
        public override int PageSize {get;} = 10;

        public Guid? TemplateId {get; set;} = null;
    
    }
}
