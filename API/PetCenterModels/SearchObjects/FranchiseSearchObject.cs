using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.SearchObjects
{
    public class FranchiseSearchObject : BaseSearchObject
    {
        public string FranchiseName { get; set; } = String.Empty;
    }
}
