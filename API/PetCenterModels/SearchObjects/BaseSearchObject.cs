using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;
using PetCenterModels.ModelUtils;

namespace PetCenterModels.SearchObjects
{
    public class BaseSearchObject
    {
        public int Page { get; set; }

        [JsonIgnore]
        [ReadOnly(true)]
        
        public virtual int PageSize {get;} = 1000;

        [JsonIgnore]
        [ReadOnly(true)]
       
        public virtual FileScope FileRW {get; set;} = FileScope.Invalid;


        [JsonIgnore]
        [ReadOnly(true)]       
        public Access AuthoritySpecifier {get; set;} = Access.User;



        [JsonIgnore]
        [ReadOnly(true)]       
        public Guid Session {get; set;} = Guid.Empty;

    }
}
