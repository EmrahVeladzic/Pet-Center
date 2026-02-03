using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Services
{
    public class UserService : BaseCRUDService<User,UserSearchObject,UserRequestDTO,UserResponseDTO>, IUserService
    {


        public UserService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Users;
        }

        public override async Task<ServiceOutput<List<UserResponseDTO>>> Get(UserSearchObject search)
        {
            List<User> entities = await dbSet.Include(u=>u.UserAccount).Where(u=>u.UserAccount!=null && u.UserName!=null && u.UserName.ToLower().StartsWith(search.UserName.ToLower()) && ((search.BusinessRelated&&u.UserAccount.AccessLevel==Access.BusinessAccount) || (!search.BusinessRelated&&u.UserAccount.AccessLevel==Access.User))).OrderBy(u=>u.Id).Skip(search.Page*search.PageSize).Take(search.PageSize).ToListAsync();
            return  ServiceOutput<List<UserResponseDTO>>.Success(entities.Select(e=>UserResponseDTO.FromEntity(e)!).ToList());
        }


        public override async Task<ServiceOutput<UserResponseDTO>> Put(Guid? token_holder,UserRequestDTO ent)
        {

            User? current = await dbContext.Users.FindAsync(ent.Id);

            if (current != null)
            {
                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        current.UserName = ent.UserName;
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();

                        return ServiceOutput<UserResponseDTO>.Success(UserResponseDTO.FromEntity(current));
                        
                    }
                    catch
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<UserResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");
                    }
                }

              

            }

            return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotFound,"No user with this ID exists.");

        }

        public override Task<ServiceOutput<UserResponseDTO>> Post(Guid? token_holder,UserRequestDTO ent)
        {
            return Task.FromResult(ServiceOutput<UserResponseDTO>.Error(HttpCode.NotImplemented,"Illegal endpoint."));
        }

        public async Task<ServiceOutput<string>> SetEmployee(Guid owner_id, Guid usr_id, Guid franchise_id, bool hire_fire)
        {

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable))
            {

                try
                {
                    User? usr =  await dbContext.Users.Include(u=>u.UserAccount).FirstOrDefaultAsync(u=>u.Id==usr_id);
                    User? owner = await dbContext.Users.FirstOrDefaultAsync(u=>u.AccountId==owner_id);
                    Franchise? franchise = await dbContext.Franchises.FindAsync(franchise_id);
                    EmployeeRecord? record = await dbContext.EmployeeRecords.FirstOrDefaultAsync(r=>r.UserId==usr_id && r.FranchiseId==franchise_id);

                    if(usr==null || owner==null || franchise==null || usr.UserAccount==null)
                    {
                        return ServiceOutput<string>.Error(HttpCode.NotFound,"One or more resources needed for this operation are missing.");
                    }

                    if (franchise.OwnerId != owner.Id)
                    {
                        return ServiceOutput<string>.Error(HttpCode.Forbidden,"The token holder does not own the specified franchise.");
                    }

                    if (usr.UserAccount.AccessLevel != Access.BusinessAccount)
                    {
                        return ServiceOutput<string>.Error(HttpCode.BadRequest,"The specified user is not eligible to be an employee.");
                    }

                    if (hire_fire)
                    {
                        if (record == null)
                        {
                            EmployeeRecord newRecord = new EmployeeRecord
                            {
                                UserId = usr_id,
                                FranchiseId = franchise_id,                       
                            };

                            await dbContext.EmployeeRecords.AddAsync(newRecord);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                        }

                        return ServiceOutput<string>.Success("Employee hired successfully.");
                    }
                    else
                    {
                        if(record!=null)
                        {
                            dbContext.EmployeeRecords.Remove(record);                            
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                        }

                        return ServiceOutput<string>.Success("Employee fired successfully.");
                    }

                            
                }
                catch
                {
                    
                    await tx.RollbackAsync();
                    return ServiceOutput<string>.Error(HttpCode.InternalError,"Internal server error.");
                }


            }


        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid? token_holder, UserRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"Request validation failure.");
            }

            User? usr = await dbSet.FindAsync(resource.Id);

            if (usr == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested user does not exist.");

            }

            if (usr.AccountId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to user.");
            }

            User? existing = await dbSet.FirstOrDefaultAsync(u=>u.UserName==resource.UserName && u.Id!=resource.Id);

            if (existing != null)
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,$"The username {resource.UserName} is already taken.");
            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid? token_holder, Guid resourceId)
        {
           User? usr = await dbContext.Users.FindAsync(resourceId);
        
            if(usr==null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested user does not exist.");
            }
        
            if(usr.AccountId!=token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to user.");
            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }
       
    }
}
