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
using PetCenterServices;
using System.Buffers.Text;
using System.Runtime.Intrinsics.Arm;
using System.Security.Cryptography;


namespace PetCenterModels.ModelUtils
{

    public enum FilePurpose : byte
    {
       Image = 0,
    }
    public enum FileScope : byte
    {
        Invalid = 0,
        ReadOnly = 1,
        Write = 2,
    }

    public sealed class MissingTransactionException : Exception
    {
        public MissingTransactionException():base("This operation requires an active transaction."){}
        public MissingTransactionException(string message):base(message){}
    }

    public static class DBUtils
    {
        public static void EnsureInTransaction(PetCenterDBContext ctx)
        {
            if (ctx.Database.CurrentTransaction == null)
            {
                throw new MissingTransactionException();
            }
        }
    }

    public static class BLOBHandler
    {
        public static string CreateHash(byte[] input)
        {
            return Convert.ToBase64String(SHA256.HashData(input));
        }

    }

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

        
    }
}
