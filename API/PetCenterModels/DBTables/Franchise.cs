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
    [Table("Franchise", Schema = "Business")]
    public class Franchise : BaseTableEntity
    {
        [Column("OwnerID")]
        [JsonIgnore]
        public Guid OwnerId { get; set; }

        
        [ForeignKey(nameof(OwnerId))]
        [JsonIgnore]
        public User? Owner { get; set; }

        [Column("FranchiseName")]
        public string? FranchiseName { get; set; }

        [Column("LogoID")]
        [JsonIgnore]
        public Guid? LogoId { get; set; }

        [ForeignKey(nameof(LogoId))]
        public Album? Logo { get; set; }

        [NotMapped]
        public List<Facility>? Facilities { get; set; }

    }
}
