using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class UserSearchObject :BaseSearchObject
    {
        public string UserName { get; set; } = String.Empty;

        public bool BusinessRelated { get; set; }
    }
}
