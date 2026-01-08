using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterModels.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IdentityModel.Tokens.Jwt;
using PetCenterServices.Utils;


namespace PetCenterServices.Interfaces
{
    public interface IAccountService : IBaseCRUDService<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO>
    {    
        public Task<ServiceOutput<string>> LogIn(AccountRequestDTO req);       
        public Task <ServiceOutput<string>> RequestAccountVerification(Guid id);
        public Task<ServiceOutput<string>> VerifyAccount(Guid id, int code);   
        public Task<ServiceOutput<string>> SetRole(Guid owner_id, Guid id, Access role);

    }
}
