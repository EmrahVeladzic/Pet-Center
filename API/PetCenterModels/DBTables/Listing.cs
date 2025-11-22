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
    [Table("Listing", Schema = "Offer")]
    public class Listing : BaseTableEntity
    {
        [Column("ListingName")]
        public string? ListingName { get; set; }
        [Column("ListingDescription")]
        public string? ListingDescription { get; set; }

        [Column("AlbumID")]
        [JsonIgnore]
        public int AlbumId { get; set; }
        [ForeignKey(nameof(AlbumId))]
        public Album? Images { get; set; }


    }
}
