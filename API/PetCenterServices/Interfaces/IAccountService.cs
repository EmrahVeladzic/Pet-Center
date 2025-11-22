using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterModels.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IdentityModel.Tokens.Jwt;


namespace PetCenterServices.Interfaces
{
    public interface IAccountService : IBaseCRUDService<Account,AccountSearchObject>
    {
        public Task Register(AccountRequestObject req);
        public Task<string?> LogIn(AccountRequestObject req);
        public Task UpdateDetails(int id, AccountRequestObject req);
        public Task<bool> CheckIfAccountExists(AccountRequestObject req);
        public Task<bool> CheckAccountVerification(int id);
        public Task RequestAccountVerification(int id);
        public Task VerifyAccount(int id, int code);


    }
}
