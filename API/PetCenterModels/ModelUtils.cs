using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Webp;


namespace PetCenterModels.ModelUtils
{
    public static class ModelValidationUtils
    {
        public static bool ValidateContact(string? contact)
        {
            if(string.IsNullOrWhiteSpace(contact)){return false;}

            EmailAddressAttribute e = new();
            return e.IsValid(contact);
        }

        public static bool IsMature(Account? acc)
        {
            if(acc==null){return false;}
            return acc.RegistrationDate.AddDays(7) <= DateTime.UtcNow;
        }

        public static bool IsWebp(byte[] bytes,short width, short height)
        {
            if (bytes.Length < 12)
                return false;

            
            bool riff =
                bytes[0] == 0x52 &&
                bytes[1] == 0x49 &&
                bytes[2] == 0x46 &&
                bytes[3] == 0x46;

           
            bool webp =
                bytes[8] == 0x57 &&
                bytes[9] == 0x45 &&
                bytes[10] == 0x42 &&
                bytes[11] == 0x50;


            if (!(riff && webp))
            {
                return false;
            }
           
            try
            {
                using SixLabors.ImageSharp.Image image = SixLabors.ImageSharp.Image.Load(bytes);

                return(width==image.Width&&height==image.Height);

            }
            catch
            {
                return false;
            }


        }
    }
}
