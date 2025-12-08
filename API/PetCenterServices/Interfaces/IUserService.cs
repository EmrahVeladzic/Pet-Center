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
        public Task<bool> CheckIfUniqueUsername(int id, string username);

        public Task SetImage(int id, UserRequestObject req);

        public Task SetUsername(int id, UserRequestObject req);



    }
}
