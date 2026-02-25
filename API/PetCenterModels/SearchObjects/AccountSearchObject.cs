using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.SearchObjects
{
    public class AccountSearchObject : BaseSearchObject
    {
        
        public Access? Role {get; set;} = null;

    }
}
