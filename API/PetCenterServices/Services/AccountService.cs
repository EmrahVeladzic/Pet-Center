using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RabbitMQ.Client;
using PetCenterShared;


namespace PetCenterServices.Services
{
    public class AccountService : BaseCRUDService<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO>, IAccountService
    {

        private IMessageBusClient message_bus_client;

        public AccountService(PetCenterDBContext ctx,IMessageBusClient client):base(ctx)
        {
            dbSet = ctx.Accounts;
            message_bus_client=client;
        }

        protected override async Task<IQueryable<Account>> Filter(Guid token_holder, AccountSearchObject search)
        {
            IQueryable<Account> output = await base.Filter(token_holder,search);
            if (search.Role != null)
            {
                output = output.Where(a=>a.AccessLevel==search.Role);
            }
            return output;
        }

        public override async Task<ServiceOutput<AccountResponseDTO>> Post(Guid token_holder,AccountRequestDTO req)
        {
              
            Account acc = new();
            acc.PasswordSalt = Utils.Crypto.GenerateSalt();
            acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
            acc.Contact = req.Contact;            

            if (await dbContext.Accounts.CountAsync() > 0)
            {
                acc.AccessLevel = (req.Business)?Access.BusinessAccount:Access.User;
                acc.Verified = false;

            }
            else
            {
                acc.AccessLevel = Access.Owner;
                acc.Verified = true;
            }

             using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {

                    await dbContext.Accounts.AddAsync(acc);
                    await dbContext.SaveChangesAsync();

                    

                    if (!acc.Verified)
                    {
                        Registration registration = new();
                        registration.Expiry = DateTime.UtcNow.AddDays(7);
                        registration.NextAttempt = DateTime.UtcNow;
                        registration.AccountId = acc.Id;
                        registration.Code = Crypto.GenerateCode();
                        await dbContext.Registrations.AddAsync(registration);
                        await dbContext.SaveChangesAsync();
                    }
                   
                    User usr = new();

                   
                    usr.Id = acc.Id;
                    usr.UserName = await Utils.UserUtils.GenerateUsername(dbContext);
                    await dbContext.Users.AddAsync(usr);
                    await dbContext.SaveChangesAsync();

                    await tx.CommitAsync();

                    Registration? reg = await dbContext.Registrations.FirstOrDefaultAsync(r=>r.AccountId==acc.Id);
                    if(!acc.Verified && reg!=null){
                                               
                        await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=acc.Contact,Message=$"Your verification code is {reg.Code}.",Subject="Welcome!",Name=usr.UserName});

                    }
                    return ServiceOutput<AccountResponseDTO>.Success(AccountResponseDTO.FromEntity(acc),HttpCode.Created);
                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<AccountResponseDTO>.FromException(ex);
                    
                }
            }
        }

        public override async Task<ServiceOutput<AccountResponseDTO>> Put(Guid token_holder,AccountRequestDTO req)
        {      

            Account? acc = await dbContext.Accounts.FindAsync(req.Id);

            if (acc != null)
            {                
                 
                acc.Contact = req.Contact;
               
                acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt!);

                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        acc.CurrentVersion=req.CurrentVersion;
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<AccountResponseDTO>.FromException(ex);
                    }
                }

                
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
                    User? usr = await dbContext.Users.Include(u=>u.UserAccount).FirstOrDefaultAsync(u=>u.Id == acc.Id);

                    if (usr != null)
                    {

                        return ServiceOutput<string>.Success(Utils.Crypto.GenerateJWT(usr));

                    }

                    return ServiceOutput<string>.Error(HttpCode.InternalError,"Account exists, but the user data for it is missing.");

                }
            }

            return ServiceOutput<string>.Error(HttpCode.Unauthorized,"Wrong Contact and/or password.");

        }

        public async Task<ServiceOutput<string>> RequestAccountVerification(Guid id)
        {
            Registration? reg = await dbContext.Registrations.Include(r=>r.RelevantAccount).ThenInclude(a=>a.AccountUser).FirstOrDefaultAsync(r=>r.AccountId==id);

            if (reg != null)
            {
                if (reg.RelevantAccount == null||reg.RelevantAccount.AccountUser==null)
                {
                    return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
                }

                reg.Code = Utils.Crypto.GenerateCode();
                await dbContext.SaveChangesAsync();
                await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=reg.RelevantAccount.Contact,Message=$"Your verification code is {reg.Code}.",Subject="Welcome!",Name=reg.RelevantAccount.AccountUser.UserName});
                return  ServiceOutput<string>.Success($"Your verification code will be sent shortly.");
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

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    
                    if (reg.Code == code) { 

                        reg.RelevantAccount.Verified = true;    
                        dbContext.Registrations.Remove(reg);  
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();


                        User? usr = await dbContext.Users.Include(u=>u.UserAccount).FirstOrDefaultAsync(u=>u.Id == id);

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
                        await tx.CommitAsync();

                        return ServiceOutput<string>.Error(HttpCode.BadRequest,"Wrong verification code. Please try again in a minute.");
                    }

                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<string>.FromException(ex);
                    
                }
            }
           
            
   

        }

    
        public async Task<ServiceOutput<string>> SetRole(Guid owner_id, Guid id, Access role)
        {

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable))
            {
                try
                {

                    Account? acc = await dbContext.Accounts.FindAsync(id);
                    if (acc != null)
                    {
                    

                        if (role!=Access.Owner && (await CheckIsLastOwner(acc)|| (owner_id!=id && acc.AccessLevel==Access.Owner)))
                        {
                            return ServiceOutput<string>.Error(HttpCode.Forbidden,"This action is not allowed.");
                        }

                        User? usr = await dbContext.Users.FindAsync(id);
                        if (usr == null)
                        {
                            return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
                        }

                        await usr.StageDeletion<User>(dbContext,dbContext.Users);

                        acc.AccessLevel = role;
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();

                        return ServiceOutput<string>.Success("Role updated.");
                            
                    }
                    return ServiceOutput<string>.Error(HttpCode.NotFound,"No account with this ID exists.");


                    
                }                       
         
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<string>.FromException(ex);                    

                }
            }

        }

        public override async Task <ServiceOutput<object>> Delete(Guid token_holder,Guid id)
        {
            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable))
            {
                try
                {

                    Account? current = await dbSet.FindAsync(id);
                    if (current != null)
                    {

             
                        if(await CheckIsLastOwner(current))
                        {
                            return ServiceOutput<object>.Error(HttpCode.Forbidden,"This action is not allowed.");
                        }                       


                        await current.StageDeletion<Account>(dbContext,dbSet);
                        await dbContext.SaveChangesAsync();                
                        await tx.CommitAsync();
                       
                    
                    }

                    return ServiceOutput<object>.Success(default,HttpCode.NoContent);
                
                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<object>.FromException(ex);
                    

                }
            }
           
        }


        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, AccountRequestDTO resource)
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

        public override Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, AccountRequestDTO resource)
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

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
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
