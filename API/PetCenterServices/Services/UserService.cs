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

        public async Task<bool> CheckIfUniqueUsername(int id, string username)
        {
            User? usr = await dbContext.Users.Where(u=>u.UserName!=null && u.UserName.Equals(username) && u.AccountId!=id && !string.IsNullOrWhiteSpace(username)).FirstOrDefaultAsync();

            return usr == null;
        }

        public async Task Delete(int id)
        {
            User? usr = await dbContext.Users.Include(u=>u.Image).Where(u=>u.Id==id).FirstOrDefaultAsync();

            if (usr != null)
            {
                if (usr.Image != null)
                {
                    dbContext.Images.Remove(usr.Image);
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

        public async Task<User?> GetById(int id)
        {
            User? user = await dbContext.Users.FindAsync(id);

            if (user != null)
            {
                await dbContext.Entry(user).Reference(u => u.Image).LoadAsync();
            }

            return user;
        }

        public async Task<List<User>> Get(UserSearchObject search)
        {

            return await dbContext.Users.Include(u=>u.Image).Where(u=>u.UserName!.ToLower().Contains((search.UserName??"").ToLower())).Skip(search.Page*50).Take(50).ToListAsync();

        }

        public async Task SetImage(int id, UserRequestObject req)
        {
            User? usr = await dbContext.Users.Include(u => u.Image).Where(u => u.AccountId == id).FirstOrDefaultAsync();

            if (usr != null)
            {
                if (usr.Image != null)
                {
                    dbContext.Images.Remove(usr.Image);
                    await dbContext.SaveChangesAsync();
                }

                if (req.Image != null && req.ImageWidth!=null && req.ImageHeight!=null)
                {
                    Image img = new();

                    img.Height = (int)req.ImageHeight!;
                    img.Width = (int)req.ImageWidth!;

                    img.Data = req.Image;
                    await dbContext.Images.AddAsync(img);
                    await dbContext.SaveChangesAsync();

                    usr.ImageId = img.Id;
                    await dbContext.SaveChangesAsync();


                }

            }

        }


        public async Task SetUsername(int id, UserRequestObject req)
        {
            User? usr = await dbContext.Users.Where(u => u.AccountId == id).FirstOrDefaultAsync();

            if (usr != null)
            {
                usr.UserName = req.UserName;
            }

        }
    }
}
