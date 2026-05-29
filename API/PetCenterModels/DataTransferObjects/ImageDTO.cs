using Microsoft.VisualBasic;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.ModelUtils;

namespace PetCenterModels.DataTransferObjects
{
    public class ImageDTO : IBLOBReferencingDTO<Image,ImageDTO,ImageMetadata>
    {
               
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        [Required]
        public Guid AlbumInsertId { get; set; } = Guid.Empty;
        [Required]
        public short Width { get; set; } = 0;
        [Required]
        public short Height { get; set; } = 0;

        public string? Token {get; set;} = null;

        public string Hash {get; set;} = string.Empty;   

        public bool CanWrite {get; set;} = false;
  

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static ImageDTO? FromEntity(Image? img)
        {
            if(img==null){return null;}
            return new ImageDTO
            {
                Id = img.Id,
                CurrentVersion=img.CurrentVersion,
                AlbumInsertId=img.AlbumId,
                Width = img.Width,
                Height = img.Height,
                Hash = img.BLOBId
            };
        }

        public static ImageDTO? FromEntity(Image? img, string token)
        {
            ImageDTO? output = ImageDTO.FromEntity(img);

            if (output != null)
            {
                output.Token=token;
            }

            return output;
        }

    }
}
