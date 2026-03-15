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

namespace PetCenterModels.DataTransferObjects
{
    public class ImageDTO : ISerializableRequestDTO<Image>, IBaseResponseDTO<Image,ImageDTO>
    {
        [JsonIgnore]
        public const short MaxDimension = 512;
        [JsonIgnore]
        public const short MinDimension = 32;

        [JsonIgnore]
        public const int MaxSize = 204800;
        
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        [Required]
        public Guid AlbumInsertId { get; set; } = Guid.Empty;
        [Required]
        public short Width { get; set; } = 0;
        [Required]
        public short Height { get; set; } = 0;
        [Required]
        public string? Data { get; set; } = null;

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
                Data = img.Data
            };
        }

        public bool Validate()
        {
            return(!string.IsNullOrWhiteSpace(Data)&&(Width >= MinDimension && Width<=MaxDimension)&&(Height>=MinDimension && Height<=MaxDimension)&&Data.Length<MaxSize&&!(AlbumInsertId==Guid.Empty));
        }

        public Image? ToEntity()
        {
            Image img = new();

            img.CurrentVersion=CurrentVersion;
            img.Width=Width;
            img.Height=Height;
            img.AlbumId = AlbumInsertId;
            img.Data = Data;
        

            return img;
        }

    }
}
