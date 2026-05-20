using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class UserSearchObject :BaseSearchObject
    {
        public string? UserName { get; set; } = null;

        public Guid? EmployedBy {get; set;} = null;

        public bool IncludeExclude {get; set;}= true;

    }
}
