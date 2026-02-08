using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Utils
{
    public static class Crypto
    {

        public static IConfiguration Configuration { get; set; } = null!;

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


        public static int GenerateCode()
        {         
            return RandomNumberGenerator.GetInt32(10000000, 100000000);
        }

 
        public static string GenerateJWT(User usr)
        {
            SymmetricSecurityKey key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["Jwt:Key"]!));
            SigningCredentials creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            Claim[] claims = new[]
            {
                new Claim(ClaimTypes.Name, usr.UserName!),
                new Claim(ClaimTypes.NameIdentifier, usr.Id.ToString()),
                new Claim(ClaimTypes.Role, UserUtils.GetRole(usr.UserAccount!.AccessLevel)),
                new Claim("verified", usr.UserAccount!.Verified ? "true" : "false")
            };

            JwtSecurityToken token = new JwtSecurityToken(
                Configuration["Jwt:Issuer"],
                Configuration["Jwt:Audience"],
                claims,
                expires: DateTime.UtcNow.AddHours(8),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);


        }
    }
}
