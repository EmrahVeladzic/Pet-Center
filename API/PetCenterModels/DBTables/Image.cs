using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Image : BaseTableEntity
    {
        public int Width { get; set; }
        public int Height { get; set; }
        public byte[]? Data { get; set; }

        [JsonIgnore]
        public int? AlbumId { get; set; }

    }
}
