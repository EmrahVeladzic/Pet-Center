using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class BaseSearchObject
    {
        public int Page { get; set; }

        [JsonIgnore]
        public virtual int PageSize {get;} = 25;


        [JsonIgnore]
        public Access AuthoritySpecifier {get; set;} = Access.User;
    }
}
