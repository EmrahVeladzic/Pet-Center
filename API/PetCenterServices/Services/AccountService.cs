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
    public class AccountService : BaseCRUDService<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO>, IAccountService
    {


        public AccountService(PetCenterDBContext ctx):base(ctx)
        {
            dbSet = ctx.Accounts;
        }

       
        public override async Task<ServiceOutput<AccountResponseDTO>> Post(Guid? token_holder,AccountRequestDTO req)
        {
              
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
                reg.AccountId = acc.Id;
                reg.Code = Crypto.GenerateCode();
                await dbContext.Registrations.AddAsync(reg);
                await dbContext.SaveChangesAsync();
            }

            Album album = new(1);  
            album.PosterID=acc.Id;          
            await dbContext.Albums.AddAsync(album);
            await dbContext.SaveChangesAsync();

            User usr = new();
            usr.AccountId = acc.Id;
            usr.UserName = await Utils.UserUtils.GenerateUsername(dbContext);
            usr.AlbumId = album.Id;
            await dbContext.Users.AddAsync(usr);
            await dbContext.SaveChangesAsync();

            return ServiceOutput<AccountResponseDTO>.Success(AccountResponseDTO.FromEntity(acc),HttpCode.Created);
        }

        public override async Task<ServiceOutput<AccountResponseDTO>> Put(Guid? token_holder,AccountRequestDTO req)
        {      

            Account? acc = await dbContext.Accounts.FindAsync(req.Id);

            if (acc != null)
            {                
                 
                acc.Contact = req.Contact;
               
                acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt!);


                await dbContext.SaveChangesAsync();
                

                return ServiceOutput<AccountResponseDTO>.Success(AccountResponseDTO.FromEntity(acc));

            }

            return  ServiceOutput<AccountResponseDTO>.Error(HttpCode.NotFound,"No account with this ID exists.");
        }

        public async Task<ServiceOutput<string>> LogIn(AccountRequestDTO req)
        {

            if (!req.Validate())
            {
                return ServiceOutput<string>.Error(HttpCode.BadRequest,"Invalid Contact and/or password.");
            }

            Account? acc = await dbContext.Accounts.FirstOrDefaultAsync(a => a.Contact == req.Contact);
            

            if (acc != null)
            {
                if (string.IsNullOrWhiteSpace(acc.PasswordSalt))
                {
                    return ServiceOutput<string>.Error(HttpCode.InternalError,"Unexpected NULL.");
                } 
                
                string login_pwd = Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
                if (login_pwd == acc.PasswordHash)
                {
                    User? usr = await dbContext.Users.Include(u=>u.UserAccount).Include(u=>u.Album).FirstOrDefaultAsync(u=>u.AccountId == acc.Id);

                    if (usr != null)
                    {

                        return ServiceOutput<string>.Success(Utils.Crypto.GenerateJWT(usr));

                    }

                }
            }

            return ServiceOutput<string>.Error(HttpCode.Unauthorized,"Wrong Contact and/or password.");

        }

        public async Task<ServiceOutput<string>> RequestAccountVerification(Guid id)
        {
            Registration? reg = await dbContext.Registrations.Include(r=>r.RelevantAccount).FirstOrDefaultAsync(r=>r.AccountId==id);

            if (reg != null)
            {
                reg.Code = Utils.Crypto.GenerateCode();
                await dbContext.SaveChangesAsync();
                return  ServiceOutput<string>.Success($"Your verification code will be sent shortly. TESTING > {reg.Code.ToString()}");
            }

            return  ServiceOutput<string>.Success("Account is already verified.");
            
        } 

        public async Task<ServiceOutput<string>> VerifyAccount(Guid id, int code)
        {
            Registration? reg = await dbContext.Registrations.Include(r => r.RelevantAccount).FirstOrDefaultAsync(r => r.AccountId == id);

            if(reg == null)
            {
                return ServiceOutput<string>.Success("Account is already verified.");
            }

            if (reg.RelevantAccount == null)
            {
                return ServiceOutput<string>.Error(HttpCode.InternalError,"Found NULL while looking for account.");
            }

            if (reg.NextAttempt > DateTime.UtcNow)
            {
                return ServiceOutput<string>.Error(HttpCode.TooManyRequests,"Too early for next attempt.");
            }

           
            if (reg.Code == code) { 

                reg.RelevantAccount.Verified = true;            
                dbContext.Registrations.Remove(reg);
                await dbContext.SaveChangesAsync();


                User? usr = await dbContext.Users.Include(u=>u.UserAccount).Include(u=>u.Album).FirstOrDefaultAsync(u=>u.AccountId == id);

                if (usr != null)
                {

                    return ServiceOutput<string>.Success(Utils.Crypto.GenerateJWT(usr));

                }

                return ServiceOutput<string>.Error(HttpCode.InternalError,"Account exists, but the user data for it is missing.");
               
                 
            }

            else
            {
                reg.NextAttempt = DateTime.UtcNow.AddMinutes(1);
                await dbContext.SaveChangesAsync();

                return ServiceOutput<string>.Error(HttpCode.BadRequest,"Wrong verification code. Please try again in a minute.");
            }
   

        }

    
        public async Task<ServiceOutput<string>> SetRole(Guid owner_id, Guid id, Access role)
        {
            Account? acc = await dbContext.Accounts.FindAsync(id);
            if (acc != null)
            {
                if (role!=Access.Owner && (await CheckIsLastOwner(acc)|| (owner_id!=id && acc.AccessLevel==Access.Owner)))
                {
                    return ServiceOutput<string>.Error(HttpCode.Forbidden,"This action is not allowed.");
                }

                acc.AccessLevel = role;
                await dbContext.SaveChangesAsync();

                return ServiceOutput<string>.Success("Role updated.");
            }

            return ServiceOutput<string>.Error(HttpCode.NotFound,"No account with this ID exists.");

        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid? token_holder, AccountRequestDTO resource)
        {           
            if (resource.Validate())
            {

                Account? existing = await dbContext.Accounts.FirstOrDefaultAsync(a=>a.Contact==resource.Contact);
                if (existing != null)
                {
                    return ServiceOutput<object>.Error(HttpCode.Conflict,"An account with the specified contact already exists.");
                }


                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
            }
            return ServiceOutput<object>.Error(HttpCode.BadRequest,"Invalid Contact and/or Password.");
        }

        public override Task<ServiceOutput<object>> IsClearedToUpdate(Guid? token_holder, AccountRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return Task.FromResult(ServiceOutput<object>.Error(HttpCode.BadRequest,"Request validation failure."));
            }
            if (token_holder == resource.Id)
            {
                return Task.FromResult(ServiceOutput<object>.Success(null,HttpCode.NoContent));
            }
            return Task.FromResult(ServiceOutput<object>.Error(HttpCode.Forbidden,"ID mismatch, unable to complete request."));
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid? token_holder, Guid resourceId)
        {
            Account? acc = await dbSet.FindAsync(token_holder);
            if (token_holder != resourceId)
            {
                if (acc == null)
                {
                    return ServiceOutput<object>.Error(HttpCode.NotFound,"The account associated with the token does not exist.");
                }
                Account? target_acc = await dbSet.FindAsync(resourceId);
                if(target_acc==null || acc.AccessLevel > target_acc.AccessLevel)
                {
                    return ServiceOutput<object>.Success(null,HttpCode.NoContent);
                }
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You lack the permissions to perform this action.");
            }
            else
            {               
                if(acc != null && await CheckIsLastOwner(acc))
                {                   
                    return ServiceOutput<object>.Error(HttpCode.BadRequest,"Cannot remove the last owner.");                        
                }
                return ServiceOutput<object>.Success(null,HttpCode.NoContent);
            }
        }


        private async Task<bool> CheckIsLastOwner(Account acc)
        {
            if (acc.AccessLevel==Access.Owner)
            {
                int count = await dbContext.Accounts.CountAsync(a=>a.AccessLevel==Access.Owner);

                if (count == 1)
                {
                    return true;
                }
            }

            return false;
        }

    }
}
