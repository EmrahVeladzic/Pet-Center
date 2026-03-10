using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Linq.Expressions;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Seeder
{
    

    public interface ISeeder
    {
        


        public Task<bool> SeedDatabase(PetCenterDBContext ctx, bool non_static_data);



    }


}