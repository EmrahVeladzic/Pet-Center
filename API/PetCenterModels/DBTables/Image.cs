using PetCenterModels.DataTransferObjects;
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
        public Guid? AlbumId { get; set; }


        public Image(ImageDTO input)
        {
            Width=input.Width;
            Height=input.Height;
            AlbumId = input.AlbumInsertId;

            string b64 = input.Data?.Replace("\r\n", "").Replace(" ", "") ?? ",TlVMTA==";
            int comma = b64.IndexOf(",");
            b64 = b64[(comma+1)..];
            Data = Convert.FromBase64String(b64);

            if (Encoding.UTF8.GetString(Data) == "NULL")
            {
                Data= null;
            }

        }

    }
}
