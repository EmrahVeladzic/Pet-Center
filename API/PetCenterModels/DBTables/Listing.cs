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
        public string? Name { get; set; }

        public string? Description { get; set; }

        [JsonIgnore]
        public int ImagesId { get; set; }
        [ForeignKey(nameof(ImagesId))]
        public Album? Images { get; set; }


    }
}
