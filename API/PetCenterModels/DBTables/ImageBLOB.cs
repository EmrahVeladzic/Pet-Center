using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.ModelUtils;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    public class ImageMetadata : IMetadataOutput
    {
        public short Width {get; set;} = 0 ;
        public short Height {get; set;} = 0;
    }

    [Table("ImageBLOB",Schema ="BLOB")]
    public class ImageBLOB : BaseBLOBEntity<ImageMetadata> , IBaseBlobEntity<ImageMetadata,ImageBLOB>
    {
        [NotMapped]
        public static short MaxDimension = 2048;

        [NotMapped]
        public static short MinDimension = 32;

        public static new ImageBLOB? TryCreateFromOctet(byte[] input, out ImageMetadata metadata)
        {
            metadata=new();


            if (input.Length < 12)
                return null;

            
            bool riff =
                input[0] == 0x52 &&
                input[1] == 0x49 &&
                input[2] == 0x46 &&
                input[3] == 0x46;

           
            bool webp =
                input[8] == 0x57 &&
                input[9] == 0x45 &&
                input[10] == 0x42 &&
                input[11] == 0x50;


            if (!(riff && webp))
            {
                return null;
            }
           
            try
            {
                using SixLabors.ImageSharp.Image image = SixLabors.ImageSharp.Image.Load(input);

                if (image.Width < MinDimension || image.Width > MaxDimension)
                {
                    return null;
                }

                metadata.Width=(short)image.Width;
                metadata.Height=(short)image.Height;

            }
            catch
            {
                return null;
            }

            ImageBLOB blob = new();

            blob.Data=input;
            blob.Id=BLOBHandler.CreateHash(input);

            return blob;

        }

    }
}

