using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterModels.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Interfaces
{
    public interface IAccountService : IBaseCRUDService<Account,AccountSearchObject>
    {
        public Task Register(AccountRequestObject req);
        public Task LogIn(AccountRequestObject req);
        public Task UpdateDetails(int id, AccountRequestObject req);
        public Task<bool> CheckIfAccountExists(AccountRequestObject req);
    }
}
