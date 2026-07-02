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

 
        public static string GenerateJWT(User usr, Guid? current)
        {
            SymmetricSecurityKey key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["Jwt:Key"]!));
            SigningCredentials creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            Claim[] claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Jti, current?.ToString()?? Guid.NewGuid().ToString()),
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

        public static string GetFilePurpose(PetCenterModels.ModelUtils.FilePurpose input)
        {
            switch (input)
            {
                case PetCenterModels.ModelUtils.FilePurpose.Image: return "Image";       
                default: throw new ArgumentOutOfRangeException(nameof(input), input, "Invalid FilePurpose.");
            }
        }

        public static string GetFileScope(PetCenterModels.ModelUtils.FileScope input)
        {
            switch (input)
            {
                case PetCenterModels.ModelUtils.FileScope.Write: return "W";    
                case PetCenterModels.ModelUtils.FileScope.ReadOnly: return "R";   
                default: throw new ArgumentOutOfRangeException(nameof(input), input, "Invalid FileScope.");
            }
        }

        public static PetCenterModels.ModelUtils.FileScope? ValidateScope(string input)
        {
            return (input) switch
            {
                "W"=>PetCenterModels.ModelUtils.FileScope.Write,
                "R"=>PetCenterModels.ModelUtils.FileScope.ReadOnly,
                _=>null
            };
        }

        public static string GenerateFileToken(String file_hash,PetCenterModels.ModelUtils.FilePurpose purpose, PetCenterModels.ModelUtils.FileScope scope, Guid album_id,Guid session, Guid user_id, string origin)
        {
            SymmetricSecurityKey key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["Jwt:Key"]!));
            SigningCredentials creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            Claim[] claims = new[]
            {             
                new Claim("file_hash",file_hash),
                new Claim("album_id",album_id.ToString()),
                new Claim("purpose",GetFilePurpose(purpose)),
                new Claim("scope", GetFileScope(scope)),
                new Claim("session",session.ToString()),
                new Claim("user_id",user_id.ToString()),
                new Claim("origin",origin)
            };

            JwtSecurityToken token = new JwtSecurityToken(
                Configuration["Jwt:Issuer"],
                Configuration["Jwt:Audience"],
                claims,
                expires: DateTime.UtcNow.AddMinutes(15),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);


        }

    }
}
