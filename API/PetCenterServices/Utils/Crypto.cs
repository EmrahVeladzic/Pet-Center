using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace PetCenterServices.Utils
{
    public static class Crypto
    {

        public static string GenerateSalt()
        {
            byte[] salt = new byte[16];

            RandomNumberGenerator.Fill(salt);

            return Convert.ToBase64String(salt);

        }

        public static string GenerateHash(string pwd, string salt)
        {
            return Convert.ToBase64String(Rfc2898DeriveBytes.Pbkdf2(Encoding.UTF8.GetBytes(pwd), Convert.FromBase64String(salt), 100000, HashAlgorithmName.SHA256, 32));
            
        }


    }
}
