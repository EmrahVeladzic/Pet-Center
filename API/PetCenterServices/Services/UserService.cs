using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Services
{
    public class UserService : BaseCRUDService<User,UserSearchObject,UserRequestDTO,UserResponseDTO>, IUserService
    {


        public UserService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Users;
        }

        public override Task<ServiceOutput<object>>Delete(Guid id)
        {           
            return Task.FromResult(ServiceOutput<object>.Error(HttpCode.NotImplemented,"Illegal endpoint."));
        }

        public override async Task<ServiceOutput<UserResponseDTO>> Put(UserRequestDTO ent)
        {

            User? current = await dbContext.Users.FindAsync(ent.Id);

            if (current != null)
            {
                current.UserName = ent.UserName;
                await dbContext.SaveChangesAsync();

                return ServiceOutput<UserResponseDTO>.Success(UserResponseDTO.FromEntity(current));

            }

            return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotFound,"No user with this ID exists.");

        }

        public override Task<ServiceOutput<UserResponseDTO>> Post(UserRequestDTO ent)
        {
            return Task.FromResult(ServiceOutput<UserResponseDTO>.Error(HttpCode.NotImplemented,"Illegal endpoint."));
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid? token_holder, UserRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"Request validation failure.");
            }

            User? usr = await dbSet.FindAsync(resource.Id);

            if (usr == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested user does not exist.");

            }

            if (usr.AccountId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to user.");
            }

            User? existing = await dbSet.FirstOrDefaultAsync(u=>u.UserName==resource.UserName && u.Id!=resource.Id);

            if (existing != null)
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,$"The username {resource.UserName} is already taken.");
            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }


       
    }
}
