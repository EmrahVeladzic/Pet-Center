using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Interfaces
{
    public interface IUserService : IBaseCRUDService<User,UserSearchObject,UserRequestDTO,UserResponseDTO>
    {         
        public Task<ServiceOutput<string>> SetEmployee(Guid owner_id, Guid usr_id, Guid franchise_id, bool hire_fire); 
    }
}
