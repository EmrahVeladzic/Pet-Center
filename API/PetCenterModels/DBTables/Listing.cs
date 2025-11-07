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
    public class Listing : BaseTableEntity
    {
        public string? ListingName { get; set; }

        public string? ListingDescription { get; set; }

        [JsonIgnore]
        public int AlbumId { get; set; }
        [ForeignKey(nameof(AlbumId))]
        public Album? Images { get; set; }


    }
}
