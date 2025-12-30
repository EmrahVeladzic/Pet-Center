using Microsoft.VisualBasic;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DataTransferObjects
{
    public class ImageDTO : ISerializableRequestDTO<Image>, IDeserializableResponseDTO<Image>
    {
        [JsonIgnore]
        public const short MaxDimension = 1024;
        [JsonIgnore]
        public const short MinDimension = 32;
        
        public Guid ImageId {get; set;}

        [Required]
        public Guid AlbumInsertId { get; set; }
        [Required]
        public short Width { get; set; } = 0;
        [Required]
        public short Height { get; set; } = 0;
        [Required]
        public string? Data { get; set; } = null;

        public ImageDTO(Image? img)
        {
            FromEntity(img);
        }

        public void FromEntity(Image? img)
        {
            if(img!=null){
                AlbumInsertId = img.AlbumId;
                Width = img.Width;
                Height = img.Height;
                Data = img.Data;
            }
        }

        public bool Validate()
        {
            return(!string.IsNullOrWhiteSpace(Data)&&(Width >= MinDimension && Width<=MaxDimension)&&(Height>=MinDimension && Height<=MaxDimension));
        }

        public Image? ToEntity()
        {
            Image img = new();

            img.Width=Width;
            img.Height=Height;
            img.AlbumId = AlbumInsertId;
            img.Data = Data;
        

            return img;
        }

    }
}
