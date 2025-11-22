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
    [Table("Image", Schema = "File")]
    public class Image : BaseTableEntity
    {
        [Column("Width")]
        public int Width { get; set; }
        [Column("Height")]
        public int Height { get; set; }
        [Column("ImageData")]
        public byte[]? Data { get; set; }
        [Column("AlbumID")]
        [JsonIgnore]
        public int? AlbumId { get; set; }

    }
}
