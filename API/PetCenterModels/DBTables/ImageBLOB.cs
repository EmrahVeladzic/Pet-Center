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
           
            try
            {
                using SixLabors.ImageSharp.Image image = SixLabors.ImageSharp.Image.Load(input);

                if (image.Width < MinDimension || image.Width > MaxDimension)
                {
                    return null;
                }

                metadata.Width=(short)image.Width;
                metadata.Height=(short)image.Height;

                if (metadata.Width * 2 < metadata.Height || metadata.Height * 2 < metadata.Width)
                {
                    return null;
                }

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

