using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    [Table("Facility", Schema = "Business")]
    public class Facility : BaseTableEntity
    {

        [Column("FranchiseID")]
        [JsonIgnore]
        public int FranchiseId { get; set; }

        [Column("Address")]
        public string? Address { get; set; }

        [Column("City")]
        public string? City { get; set; }

        [Column("Contact")]
        [Phone]
        public string? Contact {  get; set; }

    }
}
