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
using PetCenterModels.ModelUtils;
using Microsoft.Extensions.Logging;


namespace PetCenterServices.Services
{
    public class AccountService : BaseCRUDService<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO>, IAccountService
    {

        private IMessageBusClient message_bus_client;

        public AccountService(PetCenterDBContext ctx,ILoggerFactory _logger,IMessageBusClient client):base(ctx,_logger)
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
            if (!req.Validate())
            {
                return ServiceOutput<AccountResponseDTO>.Error(HttpCode.BadRequest,"Please provide a valid contact and password.");
            }

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

        await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {

                    await dbContext.Accounts.AddAsync(acc);
                    await dbContext.SaveChangesAsync();

                    int code = Crypto.GenerateCode();

                    if (!acc.Verified)
                    {
                        Registration registration = new();
                        registration.Expiry = DateTime.UtcNow.AddDays(1);
                        registration.NextAttempt = DateTime.UtcNow;
                        registration.Id = acc.Id;
                        registration.CodeSalt=Crypto.GenerateSalt();
                        registration.CodeHash =Crypto.GenerateHash(code.ToString(),registration.CodeSalt);
                        await dbContext.Registrations.AddAsync(registration);
                        await dbContext.SaveChangesAsync();
                    }
                   
                    User usr = new();

                   
                    usr.Id = acc.Id;
                    usr.UserName = await Utils.UserUtils.GenerateUsername(dbContext);
                    await dbContext.Users.AddAsync(usr);
                    await dbContext.SaveChangesAsync();

                    await tx.CommitAsync();

                    Registration? reg = await dbContext.Registrations.FindAsync(acc.Id);
                    if(!acc.Verified && reg!=null){
                                               
                        await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=acc.Contact,Message=$"Your verification code is {code}.",Subject="Welcome!",Name=usr.UserName});

                    }
                    return ServiceOutput<AccountResponseDTO>.Success(AccountResponseDTO.FromEntity(acc),HttpCode.Created);
                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<AccountResponseDTO>.FromException(ex,logger);
                    
                }
            }
        }

        public async Task<ServiceOutput<string>> TransferAccount(Guid token_holder, int old_code, int new_code)
        {
            ContactTransfer? ct = await dbContext.ContactTransfers.Include(c=>c.RelevantAccount).FirstOrDefaultAsync(c=>c.Id==token_holder);
            if (ct == null)
            {
                return ServiceOutput<string>.Error(HttpCode.NotFound,"No pending contact transfer for this account found.");
            }
            if (ct.RelevantAccount == null)
            {
                return ServiceOutput<string>.Error(HttpCode.NotFound,"No account with this ID exists.");
            }

        await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    string old_hash = Crypto.GenerateHash(old_code.ToString(),ct.OldCodeSalt);
                    string new_hash = Crypto.GenerateHash(new_code.ToString(),ct.NewCodeSalt);

                    if(old_hash!=ct.OldCodeHash || new_hash!= ct.NewCodeHash)
                    {
                        return ServiceOutput<string>.Error(HttpCode.BadRequest,"One or both of the sent codes are not correct.");
                    }

                    if (!ModelValidationUtils.ValidateContact(ct.NewContact))
                    {
                        return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
                    }

                    Account? acc = await dbSet.FirstOrDefaultAsync(a=>a.Contact==ct.NewContact);
                    if (acc != null)
                    {
                        return ServiceOutput<string>.Error(HttpCode.Conflict,"An account with this contact already exists.");
                    }

                    ct.RelevantAccount.Contact=ct.NewContact;
                    await dbContext.SaveChangesAsync();

                    await ct.StageDeletion<ContactTransfer>(dbContext,dbContext.ContactTransfers);
                    await dbContext.SaveChangesAsync();

                    await tx.CommitAsync();
                }
                catch(Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<string>.FromException(ex,logger);
                }
            }
            
            return ServiceOutput<string>.Success("Account transfered to new contact.");
            

        }

        public async Task<ServiceOutput<string>> RequestAccountTransfer(Guid token_holder, string? contact_overwrite)
        {
            if(contact_overwrite!=null && !ModelValidationUtils.ValidateContact(contact_overwrite))
            {
                return ServiceOutput<string>.Error(HttpCode.BadRequest,"Please make sure you have entered a valid contact.");
            }
            Account? acc = await dbSet.Include(a=>a.AccountUser).FirstOrDefaultAsync(a=>a.Id == token_holder);
            ContactTransfer? ctf = await dbContext.ContactTransfers.FindAsync(token_holder);
            if (acc == null)
            {
                return ServiceOutput<string>.Error(HttpCode.NotFound,"No account with this ID exists.");
            }
            if (acc.AccountUser == null)
            {
                return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
            }
            if (acc.Contact == contact_overwrite)
            {
                return ServiceOutput<string>.Error(HttpCode.Conflict,"You already use this contact.");
            }
            if(ctf==null && !ModelValidationUtils.ValidateContact(contact_overwrite))
            {
                return ServiceOutput<string>.Error(HttpCode.BadRequest,"Please provide a contact to transfer your account to.");
            }
            int old_code = Crypto.GenerateCode();
            int new_code = Crypto.GenerateCode();
            string old_salt= Crypto.GenerateSalt();
            string new_salt= Crypto.GenerateSalt();
            string old_hash = Crypto.GenerateHash(old_code.ToString(),old_salt);
            string new_hash = Crypto.GenerateHash(new_code.ToString(),new_salt);
            DateTime expiry = DateTime.UtcNow.AddHours(6);
            ContactTransfer transfer=new();
            try{
                
                if (ctf == null)
                {
                    transfer.Id=token_holder;
                    transfer.NewContact=contact_overwrite!;
                    transfer.Expiry = expiry;
                    transfer.OldCodeSalt=old_salt;
                    transfer.OldCodeHash=old_hash;
                    transfer.NewCodeSalt=new_salt;
                    transfer.NewCodeHash=new_hash;
                    await dbContext.ContactTransfers.AddAsync(transfer);
                }
                else
                {                   
                    if (ModelValidationUtils.ValidateContact(contact_overwrite))
                    {                       
                        ctf.NewContact=contact_overwrite!;
                    }
                    ctf.Expiry=expiry;
                    ctf.OldCodeSalt=old_salt;
                    ctf.OldCodeHash=old_hash;
                    ctf.NewCodeSalt=new_salt;
                    ctf.NewCodeHash=new_hash;

                    transfer=ctf;
                }
                await dbContext.SaveChangesAsync();
            }
            catch(Exception ex)
            {
                return ServiceOutput<string>.FromException(ex,logger);
            }
            await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=acc.Contact,Message=$"Your first transfer code is {old_code}.",Subject="Account transfer",Name=acc.AccountUser.UserName});
            await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=transfer.NewContact,Message=$"Your second transfer code is {new_code}.",Subject="Account transfer",Name=acc.AccountUser.UserName});

            return ServiceOutput<string>.Success("Your account transfer code pair will be sent shortly.");
        }

        public override async Task<ServiceOutput<AccountResponseDTO>> Put(Guid token_holder,AccountRequestDTO req)
        {      

            Account? acc = await dbContext.Accounts.FindAsync(req.Id);

            if (acc != null)
            {                

                bool updated_contact = false;
                bool updated_password = false;

                if (!string.IsNullOrWhiteSpace(req.Contact))
                {
                    ServiceOutput<string> s_out = await RequestAccountTransfer(token_holder,req.Contact);
                    
                    updated_contact = ServiceOutput<string>.IsSuccess(s_out);

                    if(!updated_contact){return ServiceOutput<AccountResponseDTO>.Error(s_out.Code,s_out.ErrorMessage!);}
                }
                

                if (!string.IsNullOrWhiteSpace(req.Password))
                {
                    acc.PasswordSalt=Utils.Crypto.GenerateSalt();
                    acc.PasswordHash = Utils.Crypto.GenerateHash(req.Password!, acc.PasswordSalt!);
                    updated_password = true;
                }
                else
                {
                    if (string.IsNullOrEmpty(req.Contact))
                    {
                        if(string.IsNullOrWhiteSpace(req.Password)){return ServiceOutput<AccountResponseDTO>.Error(HttpCode.BadRequest,"You cannot have an empty password.");}
                    }
                } 

                
               
                try
                {
                    acc.CurrentVersion=req.CurrentVersion;
                    await dbContext.SaveChangesAsync();
                       
                }
                catch(Exception ex)
                {
                        
                    return ServiceOutput<AccountResponseDTO>.FromException(ex,logger);
                }
                
                
                AccountResponseDTO output = AccountResponseDTO.FromEntity(acc)!;

                output.Notes = new();

                const string pending = "pending.";
                const string changed = "changed.";
                const string unchanged = "unchanged.";

                output.Notes.Add(new NoteSubDTO{Title="Updates",Body=$"Contact - {(updated_contact? pending:unchanged)} Password - {(updated_password? changed: unchanged)}"});
                
                return ServiceOutput<AccountResponseDTO>.Success(output);

            }

            return  ServiceOutput<AccountResponseDTO>.Error(HttpCode.NotFound,"No account with this ID exists.");
        }

        public async Task<ServiceOutput<string>> LogIn(AccountRequestDTO req)
        {

            if (!req.Validate())
            {
                return ServiceOutput<string>.Error(HttpCode.BadRequest,"Please provide a valid contact and password.");
            }


            Account? acc = await dbContext.Accounts.FirstOrDefaultAsync(a => a.Contact == req.Contact);
            

            if (acc != null)
            {
                SingleTimeEntry? entry = await dbContext.SingleTimeEntries.FindAsync(acc.Id);
               
                string login_pwd = Crypto.GenerateHash(req.Password!, acc.PasswordSalt);
                string single_time_pwd = string.Empty;

                if (entry != null)
                {
                    single_time_pwd = Crypto.GenerateHash(req.Password,entry.CodeSalt);
                }

                if (login_pwd == acc.PasswordHash || single_time_pwd==entry?.CodeHash)
                {
                    User? usr = await dbContext.Users.Include(u=>u.UserAccount).FirstOrDefaultAsync(u=>u.Id == acc.Id);

                    if (usr != null)
                    {
                        if (entry != null)
                        {
                            dbContext.SingleTimeEntries.Remove(entry);
                            await dbContext.SaveChangesAsync();
                        }

                        return ServiceOutput<string>.Success(Utils.Crypto.GenerateJWT(usr));

                    }

                    return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");

                }
            }

            return ServiceOutput<string>.Error(HttpCode.Unauthorized,"Wrong Contact and/or password.");

        }

        public async Task<ServiceOutput<string>> RequestAccountVerification(Guid id)
        {
            Registration? reg = await dbContext.Registrations.Include(r=>r.RelevantAccount).ThenInclude(a=>a.AccountUser).FirstOrDefaultAsync(r=>r.Id==id);

            if (reg != null)
            {
                if (reg.RelevantAccount == null||reg.RelevantAccount.AccountUser==null)
                {
                    return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
                }

                int code = Utils.Crypto.GenerateCode();
                reg.CodeSalt=Crypto.GenerateSalt();
                reg.CodeHash=Crypto.GenerateHash(code.ToString(),reg.CodeSalt);

                await dbContext.SaveChangesAsync();
                await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=reg.RelevantAccount.Contact,Message=$"Your verification code is {code}.",Subject="Welcome!",Name=reg.RelevantAccount.AccountUser.UserName});
                return  ServiceOutput<string>.Success($"Your verification code will be sent shortly.");
            }

            return  ServiceOutput<string>.Success("Account is already verified.");
            
        } 

        public async Task<ServiceOutput<string>> RequestSingleTimeEntryCode(string contact)
        {

            if (!ModelValidationUtils.ValidateContact(contact))
            {
                return ServiceOutput<string>.Error(HttpCode.BadRequest,"Invalid contact");
            }

            Account? acc = await dbContext.Accounts.Include(a=>a.AccountUser).FirstOrDefaultAsync(a=>a.Contact==contact);

            if (acc == null)
            {
                return ServiceOutput<string>.Error(HttpCode.NotFound,"The account with the provided contact does not exist.");
            }
            if (acc.AccountUser == null)
            {                
                return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
            }

            SingleTimeEntry? temp = await dbContext.SingleTimeEntries.FindAsync(acc.Id);

            int code = Utils.Crypto.GenerateCode();
            string salt=Crypto.GenerateSalt();
            string hash=Crypto.GenerateHash(code.ToString(),salt);
            DateTime expiry = DateTime.UtcNow.AddHours(3);

            if (temp!=null){
                temp.CodeHash=hash;
                temp.CodeSalt=salt;
                temp.Expiry=expiry;                
            }
            else
            {
                SingleTimeEntry ste = new SingleTimeEntry{Id=acc.Id,Expiry=expiry,CodeSalt=salt,CodeHash=hash};
                await dbContext.SingleTimeEntries.AddAsync(ste);
            }          

            await dbContext.SaveChangesAsync();
            await message_bus_client.SendEmailMessage(new ConsumerMessage(){Contact=acc.Contact,Message=$"Your one-time entry code is {code}. You may use it once instead of your password.",Subject="Account recovery",Name=acc.AccountUser.UserName});
            return  ServiceOutput<string>.Success($"Your one-time entry code will be sent shortly.");
                       
            
        } 

        public async Task<ServiceOutput<string>> VerifyAccount(Guid id, int code)
        {
            Registration? reg = await dbContext.Registrations.Include(r => r.RelevantAccount).FirstOrDefaultAsync(r => r.Id == id);

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

        await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    string hash = Crypto.GenerateHash(code.ToString(),reg.CodeSalt);
                    
                    if (string.Equals(reg.CodeHash, hash, StringComparison.Ordinal)) { 

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
                    return ServiceOutput<string>.FromException(ex,logger);
                    
                }
            }
           
            
   

        }

        public async Task<ServiceOutput<object>> LogOut(Guid token_id, DateTime exp)
        {          

            try{

                InvalidatedToken? jwt = await dbContext.InvalidatedTokens.FindAsync(token_id);

                if (jwt == null)
                {
                    await dbContext.InvalidatedTokens.AddAsync(new InvalidatedToken{Id=token_id,Expiry=exp});
                    await dbContext.SaveChangesAsync();
                   
                }                    

                return ServiceOutput<object>.Success(null,HttpCode.NoContent);

            }
            catch(Exception ex)
            {
                   
                return ServiceOutput<object>.FromException(ex,logger);
                    
            }
            
        }

    
        public async Task<ServiceOutput<string>> SetRole(Guid owner_id, Guid id, Access role)
        {

        await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable))
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
                    return ServiceOutput<string>.FromException(ex,logger);                    

                }
            }

        }

        public override async Task <ServiceOutput<object>> Delete(Guid token_holder,Guid id)
        {
        await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable))
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
                    return ServiceOutput<object>.FromException(ex,logger);
                    

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
