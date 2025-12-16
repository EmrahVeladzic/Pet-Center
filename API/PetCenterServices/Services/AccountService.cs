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

        public async Task<Account?> GetById(Guid id)
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

        public async Task Delete(Guid id)
        {
            Account? current = await dbContext.Accounts.FindAsync(id);
            if (current != null)
            {
                User usr = await dbContext.Users.Include(u=>u.Picture).Where(u=>u.AccountId == current.Id).FirstAsync();
                if (usr.Picture != null)
                {
                    dbContext.Albums.Remove(usr.Picture);
                    await dbContext.SaveChangesAsync();
                }
                dbContext.Users.Remove(usr);
                await dbContext.SaveChangesAsync();
                dbContext.Accounts.Remove(current);
                await dbContext.SaveChangesAsync();
            }
        }

        public async Task Register(AccountRequestDTO req)
        {
            if (string.IsNullOrWhiteSpace(req.Contact) || string.IsNullOrWhiteSpace(req.Password))
            {
                return;
            }

            if (!UserUtils.ValidateContact(req.Contact))
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
            usr.PictureId = null;
            await dbContext.Users.AddAsync(usr);
            await dbContext.SaveChangesAsync();

        }

        public async Task<string?> LogIn(AccountRequestDTO req)
        {
            Account? acc = null;

            if (!string.IsNullOrWhiteSpace(req.Contact))
            {
                acc = await dbContext.Accounts.FirstOrDefaultAsync(a => a.Contact == req.Contact);
            }

            if (acc != null && !string.IsNullOrWhiteSpace(req.Password) && !string.IsNullOrWhiteSpace(acc.PasswordSalt))
            {               
                
                string login_pwd = Crypto.GenerateHash(req.Password, acc.PasswordSalt);
                if (login_pwd == acc.PasswordHash)
                {
                    User? usr = await dbContext.Users.Include(u=>u.UserAccount).Include(u=>u.Picture).FirstOrDefaultAsync(u=>u.AccountId == acc.Id);

                    if (usr != null)
                    {

                        return Utils.Crypto.GenerateJWT(usr);

                    }

                }
            }

            return null;

        }

        public async Task UpdateDetails(Guid id, AccountRequestDTO req)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);

            if (acc != null)
            {
               
                if (string.IsNullOrWhiteSpace(req.Contact) || (acc.Contact != req.Contact && ! await dbContext.Accounts.AnyAsync(a => a.Contact == req.Contact && a.Id != id)))
                {
                    acc.Contact = req.Contact;
                }              

                if (!string.IsNullOrWhiteSpace(req.Password)&&!string.IsNullOrWhiteSpace(acc.PasswordSalt))
                {
                    acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
                }
                await dbContext.SaveChangesAsync();

            }
        }

        public async Task<bool> CheckIfAccountExists(AccountRequestDTO req)
        {
            return await dbContext.Accounts.AnyAsync(a=>a.Contact == req.Contact);
        }

        public async Task<bool> CheckAccountVerification(Guid id)
        {
            Account? acc = await dbContext.Accounts.FirstOrDefaultAsync(a=>a.Id==id);

            if (acc == null)
            {

                return false;

            }

            return acc.Verified;
        }

        public async Task RequestAccountVerification(Guid id)
        {
            Registration? reg = await dbContext.Registrations.Include(r=>r.RelevantAccount).FirstOrDefaultAsync(r=>r.AccountID==id);

            if (reg != null)
            {
                reg.Code = Utils.Crypto.GenerateCode();
                await dbContext.SaveChangesAsync();
            }
        } 

        public async Task VerifyAccount(Guid id, int code)
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

        public async Task DeleteAccount(Guid id)
        {
      
            Account? acc = await dbContext.Accounts.FindAsync(id);

            if (acc != null)
            {
                User? usr = await dbContext.Users.Include(u=>u.Picture).FirstOrDefaultAsync(u => u.AccountId == id);

                if (usr != null && usr.Picture!=null)
                {
                    
                    dbContext.Albums.Remove(usr.Picture!);

                    await dbContext.SaveChangesAsync();
                                       

                }

                dbContext.Accounts.Remove(acc);

                await dbContext.SaveChangesAsync();

            }

        }

        public async Task<bool> CheckIsLastOwner(Guid id)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);
            if (acc?.AccessLevel==Access.Owner)
            {
                int count = await dbContext.Accounts.CountAsync(a=>a.AccessLevel==Access.Owner);

                if (count == 1)
                {
                    return true;
                }
            }

            return false;
        }

        public async Task<bool> CheckIsAuthorizedToModify(Guid admin, Guid target)
        {
            Account? adm = await dbContext.Accounts.FindAsync(admin);
            Account? tgt = await dbContext.Accounts.FindAsync(target);

            return (adm != null && tgt != null && adm != tgt && adm.AccessLevel > tgt.AccessLevel);
           
        }

        public async Task SetRole(Guid id, Access role)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);
            if (acc != null)
            {
                acc.AccessLevel = role;
                await dbContext.SaveChangesAsync();
            }

        }
    }
}
