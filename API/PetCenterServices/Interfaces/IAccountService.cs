using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterModels.DataTransferObjects;
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
        public Task <ServiceOutput<string>> RequestAccountTransfer(Guid id, string? contact_overwrite);
        public Task <ServiceOutput<string>> RequestSingleTimeEntryCode(string contact);
        public Task<ServiceOutput<string>> VerifyAccount(Guid id, int code, Guid session);  
        public Task<ServiceOutput<string>> TransferAccount(Guid id, int old_code, int new_code);
        public Task<ServiceOutput<string>> SetRole(Guid owner_id, Guid id, Access role);
        public Task<ServiceOutput<object>> LogOut(Guid token_id, DateTime exp);
        
    }
}
