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
        public Task UpdateDetails(Guid id, AccountRequestObject req);
        public Task<bool> CheckIfAccountExists(AccountRequestObject req);
        public Task<bool> CheckAccountVerification(Guid id);
        public Task RequestAccountVerification(Guid id);
        public Task VerifyAccount(Guid id, int code);
        public Task<bool> CheckIsLastOwner(Guid id);
        public Task<bool> CheckIsAuthorizedToModify(Guid admin, Guid target);
        public Task SetRole(Guid id, Access role);

    }
}
