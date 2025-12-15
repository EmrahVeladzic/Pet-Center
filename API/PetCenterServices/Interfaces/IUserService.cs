using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Interfaces
{
    public interface IUserService : IBaseCRUDService<User,UserSearchObject>
    {
        public Task<bool> CheckIfUniqueUsername(Guid id, string username);

        public Task SetImage(Guid id, UserRequestDTO req);

        public Task SetUsername(Guid id, UserRequestDTO req);



    }
}
