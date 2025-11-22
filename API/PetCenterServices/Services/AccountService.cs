using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
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
            if (string.IsNullOrEmpty(req.Contact) || string.IsNullOrEmpty(req.Password))
            {
                return;
            }

            EmailAddressAttribute e = new();
            PhoneAttribute p = new();

            if (!e.IsValid(req.Contact) && !p.IsValid(req.Contact))
            {
                return;
            }



            Account acc = new();
            acc.PasswordSalt = Utils.Crypto.GenerateSalt();
            acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
            acc.Contact = req.Contact;            

            if (await dbContext.Accounts.CountAsync() > 0)
            {
                acc.AccessLevel = Access.User;
                acc.Verified = false;
            }
            else
            {
                acc.AccessLevel = Access.Owner;
                acc.Verified = true;
            }

            await dbContext.Accounts.AddAsync(acc);
            await dbContext.SaveChangesAsync();

            if (!acc.Verified)
            {
                Registration reg = new();
                reg.Expiry = DateTime.UtcNow.AddDays(7);
                reg.NextAttempt = DateTime.UtcNow;
                reg.AccountID = acc.Id;
                reg.Code = Crypto.GenerateCode();
                await dbContext.Registrations.AddAsync(reg);
                await dbContext.SaveChangesAsync();
            }

            User usr = new();
            usr.AccountId = acc.Id;
            usr.UserName = Utils.UserUtils.GenerateUsername(dbContext);
            usr.ImageId = null;
            await dbContext.Users.AddAsync(usr);
            await dbContext.SaveChangesAsync();

        }

        public async Task<string?> LogIn(AccountRequestObject req)
        {
            Account? acc = null;

            if (!string.IsNullOrEmpty(req.Contact))
            {
                acc = await dbContext.Accounts.FirstOrDefaultAsync(a => a.Contact == req.Contact);
            }

            if (acc != null && !string.IsNullOrEmpty(req.Password) && !string.IsNullOrEmpty(acc.PasswordSalt))
            {               
                
                string login_pwd = Crypto.GenerateHash(req.Password, acc.PasswordSalt);
                if (login_pwd == acc.PasswordHash)
                {
                    User? usr = await dbContext.Users.Include(u=>u.UserAccount).Include(u=>u.Image).FirstOrDefaultAsync(u=>u.AccountId == acc.Id);

                    if (usr != null)
                    {

                        return Utils.Crypto.GenerateJWT(usr);

                    }

                }
            }

            return null;

        }

        public async Task UpdateDetails(int id, AccountRequestObject req)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);

            if (acc != null)
            {
               
                if (string.IsNullOrEmpty(req.Contact) || (acc.Contact != req.Contact && ! await dbContext.Accounts.AnyAsync(a => a.Contact == req.Contact && a.Id != id)))
                {
                    acc.Contact = req.Contact;
                }              

                if (!string.IsNullOrEmpty(req.Password)&&!string.IsNullOrEmpty(acc.PasswordSalt))
                {
                    acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
                }
                await dbContext.SaveChangesAsync();

            }
        }

        public async Task<bool> CheckIfAccountExists(AccountRequestObject req)
        {
            return await dbContext.Accounts.AnyAsync(a=>a.Contact == req.Contact);
        }

        public async Task<bool> CheckAccountVerification(int id)
        {
            Account? acc = await dbContext.Accounts.FirstOrDefaultAsync(a=>a.Id==id);

            if (acc == null)
            {

                return false;

            }

            return acc.Verified;
        }

        public async Task RequestAccountVerification(int id)
        {
            Registration? reg = await dbContext.Registrations.Include(r=>r.RelevantAccount).FirstOrDefaultAsync(r=>r.AccountID==id);

            if (reg != null)
            {
                reg.Code = Utils.Crypto.GenerateCode();
                await dbContext.SaveChangesAsync();
            }
        } 

        public async Task VerifyAccount(int id, int code)
        {
            Registration? reg = await dbContext.Registrations.Include(r => r.RelevantAccount).FirstOrDefaultAsync(r => r.AccountID == id);

            if (reg != null && reg.RelevantAccount != null && reg.NextAttempt<DateTime.UtcNow)
            {

                if (reg.Code == code) { 

                    reg.RelevantAccount.Verified = true;
                    await dbContext.SaveChangesAsync();

                    dbContext.Registrations.Remove(reg);
                    await dbContext.SaveChangesAsync();

                }

                else
                {
                    reg.NextAttempt = DateTime.UtcNow.AddMinutes(1);
                    await dbContext.SaveChangesAsync();
                }
            }

        }
    }
}
