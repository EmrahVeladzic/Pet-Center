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
    public class AccountService : IAccountService
    {
        protected PetCenterDBContext dbContext;

        public AccountService(PetCenterDBContext ctx)
        {
            dbContext = ctx;
        }

        public async Task<List<Account>> Get(AccountSearchObject search)
        {
            return await dbContext.Accounts.OrderBy(a=>a.Id).Skip(search.Page*50).Take(50).ToListAsync();
        }

        public async Task<Account?> GetById(int id)
        {
            return await dbContext.Accounts.FindAsync(id);
        }

        public async Task Post(Account ent)
        {
            await dbContext.Accounts.AddAsync(ent);
            await dbContext.SaveChangesAsync();
        }

        public async Task Put(Account ent)
        {
            Account? current = await dbContext.Accounts.FindAsync(ent.Id);
            if (current != null)
            {
                dbContext.Accounts.Entry(current).CurrentValues.SetValues(ent);
                await dbContext.SaveChangesAsync();
            }
        }

        public async Task Delete(int id)
        {
            Account? current = await dbContext.Accounts.FindAsync(id);
            if (current != null)
            {
                User usr = await dbContext.Users.Where(u=>u.AccountId == current.Id).FirstAsync();
                dbContext.Users.Remove(usr);
                await dbContext.SaveChangesAsync();
                dbContext.Accounts.Remove(current);
                await dbContext.SaveChangesAsync();
            }
        }

        public async Task Register(AccountRequestObject req)
        {
            Account acc = new();
            acc.PasswordSalt = Utils.Crypto.GenerateSalt();
            acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
            acc.Email = req.Email;
            acc.PhoneNumber = req.PhoneNumber;

            if (await dbContext.Accounts.CountAsync() > 0)
            {
                acc.AccessLevel = Access.User;
            }
            else
            {
                acc.AccessLevel = Access.Owner;
            }

            await dbContext.Accounts.AddAsync(acc);
            await dbContext.SaveChangesAsync();

            User usr = new();
            usr.AccountId = acc.Id;
            usr.UserName = Utils.UserUtils.GenerateUsername(dbContext);
            usr.ImageId = null;

            await Task.CompletedTask;

        }

        public async Task LogIn(AccountRequestObject req)
        {
            await Task.CompletedTask;

        }

        public async Task UpdateDetails(int id, AccountRequestObject req)
        {
            await Task.CompletedTask;
        }

        public async Task<bool> CheckIfAccountExists(AccountRequestObject req)
        {
            return await dbContext.Accounts.AnyAsync(a=>a.Email==req.Email||a.PhoneNumber==req.PhoneNumber);
        }
    }
}
