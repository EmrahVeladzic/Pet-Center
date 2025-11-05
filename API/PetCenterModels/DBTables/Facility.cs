using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Facility : BaseTableEntity
    {
       
        [JsonIgnore]
        public int FranchiseId { get; set; }

        public string? Address { get; set; }
        public string? City { get; set; }

        [Phone]
        public string? Contact {  get; set; }

    }
}
