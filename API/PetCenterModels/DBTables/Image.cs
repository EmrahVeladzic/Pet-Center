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
    public class Image : BLOBReferencingEntity<ImageMetadata>
    {
        [Column("Width")]
        public short Width { get; set; }
        [Column("Height")]
        public short Height { get; set; }            


        public override void LoadMetadata(ImageMetadata metadata)
        {
            Width=metadata.Width;
            Height=metadata.Height;
        }
       
    }
}
