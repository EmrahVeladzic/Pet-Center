using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
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

        public async Task<bool> CheckIfUniqueUsername(Guid id, string username)
        {
            if (string.IsNullOrWhiteSpace(username) || username.Equals("Null", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            User? usr = await dbContext.Users.Where(u=>u.UserName!=null && u.UserName.Equals(username) && u.AccountId!=id).FirstOrDefaultAsync();

            return usr == null;
        }

        public async Task Delete(Guid id)
        {
            User? usr = await dbContext.Users.Include(u=>u.Picture).Where(u=>u.Id==id).FirstOrDefaultAsync();

            if (usr != null)
            {
                if (usr.Picture != null)
                {
                    dbContext.Albums.Remove(usr.Picture);
                    await dbContext.SaveChangesAsync();
                }

                dbContext.Users.Remove(usr);
                await dbContext.SaveChangesAsync();
            }
        }

        public async Task Put(User ent)
        {
            User? current = await dbContext.Users.FindAsync(ent.Id);

            if (current != null)
            {
                dbContext.Users.Entry(current).CurrentValues.SetValues(ent);
                await dbContext.SaveChangesAsync();

            }

        }

        public async Task Post(User ent)
        {
            await dbContext.Users.AddAsync(ent);
            await dbContext.SaveChangesAsync();
        }

        public async Task<User?> GetById(Guid id)
        {
            User? user = await dbContext.Users.FindAsync(id);

            if (user != null)
            {
                await dbContext.Entry(user).Reference(u => u.Picture).LoadAsync();
            }

            return user;
        }

        public async Task<List<User>> Get(UserSearchObject search)
        {

            return await dbContext.Users.Include(u=>u.Picture).Where(u=>u.UserName!.ToLower().Contains((search.UserName??"").ToLower())).Skip(search.Page*50).Take(50).ToListAsync();

        }

       
        public async Task SetUsername(Guid id, UserRequestDTO req)
        {
            User? usr = await dbContext.Users.Where(u => u.AccountId == id).FirstOrDefaultAsync();

            if (usr != null)
            {
                usr.UserName = req.UserName;
            }

        }
    }
}
