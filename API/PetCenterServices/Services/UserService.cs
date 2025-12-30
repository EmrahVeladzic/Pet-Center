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
    public class UserService : IUserService
    {
        protected PetCenterDBContext dbContext;


        public UserService(PetCenterDBContext ctx)
        {
            dbContext = ctx;
        }

        public async Task<ServiceOutput<object>>Delete(Guid id)
        {         
            await Task.CompletedTask;
            return ServiceOutput<object>.Error(HttpCode.NotImplemented,"Illegal endpoint.");
        }

        public async Task<ServiceOutput<UserResponseDTO>> Put(UserRequestDTO ent)
        {

            bool valid = ent.Validate();
            if (!valid)
            {
                return ServiceOutput<UserResponseDTO>.Error(HttpCode.BadRequest,"Invalid request.");
            }

            User? current = await dbContext.Users.FindAsync(ent.Id);

            if (current != null)
            {
                current.UserName = ent.UserName;
                await dbContext.SaveChangesAsync();

                return ServiceOutput<UserResponseDTO>.Success(new UserResponseDTO(current));

            }

            return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotFound,"No user with this ID exists.");

        }

        public async Task<ServiceOutput<UserResponseDTO>> Post(UserRequestDTO ent)
        {
            await Task.CompletedTask;
            return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotImplemented,"Illegal endpoint.");
        }

        public async Task<ServiceOutput<UserResponseDTO>> GetById(Guid id)
        {
            User? user = await dbContext.Users.FindAsync(id);

            if(user==null){
                
                return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotFound,"No user with this ID exists.");
                
            }

            return ServiceOutput<UserResponseDTO>.Success(new UserResponseDTO(user));
           
            
        }

        public async Task<ServiceOutput<List<UserResponseDTO>>> Get(UserSearchObject search)
        {

            return ServiceOutput<List<UserResponseDTO>>.Success(await dbContext.Users.Where(u=>u.UserName!.ToLower().Contains((search.UserName??"").ToLower())).Skip(search.Page*search.PageSize).Take(search.PageSize).Select(u=>new UserResponseDTO(u)).ToListAsync());

        }

       
    }
}
