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

        public async Task<ServiceOutput<List<AccountResponseDTO>>> Get(AccountSearchObject search)
        {
            return  ServiceOutput<List<AccountResponseDTO>>.Success(await dbContext.Accounts.OrderBy(a=>a.Id).Skip(search.Page*search.PageSize).Take(search.PageSize).Select(a=> new AccountResponseDTO(a)).ToListAsync());
        }

        public async Task<ServiceOutput<AccountResponseDTO>> GetById(Guid id)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);

            if (acc == null) 
            {               
                return ServiceOutput<AccountResponseDTO>.Error(HttpCode.NotFound, "No account with this ID exists.");
            }

            return  ServiceOutput<AccountResponseDTO>.Success(new AccountResponseDTO(acc));
        }

        public async Task<ServiceOutput<AccountResponseDTO>> Post(AccountRequestDTO req)
        {
            bool valid = req.Validate();
            if (!valid)
            {
                return ServiceOutput<AccountResponseDTO>.Error(HttpCode.BadRequest,"Invalid request.");
            }
           
            Account? existing = await dbContext.Accounts.FirstOrDefaultAsync(a=>a.Contact==req.Contact);
            if (existing != null)
            {
                return ServiceOutput<AccountResponseDTO>.Error(HttpCode.Conflict,"An account with the specified contact already exists.");
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

            Album album = new();
            await dbContext.Albums.AddAsync(album);
            await dbContext.SaveChangesAsync();

            User usr = new();
            usr.AccountId = acc.Id;
            usr.UserName = await Utils.UserUtils.GenerateUsername();
            usr.PictureId = album.Id;
            await dbContext.Users.AddAsync(usr);
            await dbContext.SaveChangesAsync();

            return ServiceOutput<AccountResponseDTO>.Success(new AccountResponseDTO(acc),HttpCode.Created);
        }

        public async Task<ServiceOutput<AccountResponseDTO>> Put(AccountRequestDTO req)
        {      

            Account? acc = await dbContext.Accounts.FindAsync(req.Id);

            if (acc != null)
            {

                if (!string.IsNullOrEmpty(req.Contact))
                {
                    
                    EmailAddressAttribute e = new();

                    if (e.IsValid(req.Contact))
                    {
                        Account? existing = await dbContext.Accounts.FirstOrDefaultAsync(a=>a.Contact==req.Contact && a.Id!=req.Id);
                        if (existing != null)
                        {
                            return ServiceOutput<AccountResponseDTO>.Error(HttpCode.Conflict,"An account with the specified contact already exists.");
                        }

                        acc.Contact = req.Contact;
                    }

                    else{

                        return ServiceOutput<AccountResponseDTO>.Error(HttpCode.BadRequest,"Invalid contact.");

                    }
                }              
                

                if (!string.IsNullOrWhiteSpace(req.Password))
                {
                    acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt!);
                }

                await dbContext.SaveChangesAsync();
                

                return ServiceOutput<AccountResponseDTO>.Success(new AccountResponseDTO(acc));

            }

            return  ServiceOutput<AccountResponseDTO>.Error(HttpCode.NotFound,"No account with this ID exists.");
        }

        public async Task <ServiceOutput<object>> Delete(Guid id)
        {
            Account? current = await dbContext.Accounts.FindAsync(id);
            if (current != null)
            {
                dbContext.Accounts.Remove(current);
                await dbContext.SaveChangesAsync();                
            }

            return ServiceOutput<object>.Success(default,HttpCode.NoContent);
        }

        public async Task<ServiceOutput<string>> LogIn(AccountRequestDTO req)
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

                        return ServiceOutput<string>.Success(Utils.Crypto.GenerateJWT(usr));

                    }

                }
            }

            return ServiceOutput<string>.Error(HttpCode.Unauthorized,"Wrong Contact and/or password.");

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

        public async Task<ServiceOutput<string>> RequestAccountVerification(Guid id)
        {
            Registration? reg = await dbContext.Registrations.Include(r=>r.RelevantAccount).FirstOrDefaultAsync(r=>r.AccountID==id);

            if (reg != null)
            {
                reg.Code = Utils.Crypto.GenerateCode();
                await dbContext.SaveChangesAsync();
            }

            return  ServiceOutput<string>.Success("Your verification code will be sent shortly.");
        } 

        public async Task<ServiceOutput<string>> VerifyAccount(Guid id, int code)
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

                    return ServiceOutput<string>.Error(HttpCode.BadRequest,"Wrong verification code. Please try again in a minute.");
                }
            }

            return ServiceOutput<string>.Success("Account verified.");

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

        public async Task<ServiceOutput<string>> SetRole(Guid id, Access role)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);
            if (acc != null)
            {
                acc.AccessLevel = role;
                await dbContext.SaveChangesAsync();

                return ServiceOutput<string>.Success("Role updated.");
            }

            return ServiceOutput<string>.Error(HttpCode.NotFound,"No account with this ID exists.");

        }
    }
}
