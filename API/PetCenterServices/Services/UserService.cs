using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterServices.Recommender;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Logging;
using PetCenterModels.ModelUtils;

namespace PetCenterServices.Services
{
    public class UserService : BaseCRUDService<User,UserSearchObject,UserRequestDTO,UserResponseDTO>, IUserService
    {

        private readonly IRecommenderSystem recommender;

        public UserService(PetCenterDBContext ctx,ILoggerFactory _ilogger, IRecommenderSystem rec) : base(ctx,_ilogger)
        {
            dbSet = ctx.Users;
            recommender = rec;
        }


        protected override Task<IQueryable<User>> Filter(Guid token_holder, UserSearchObject search)
        {
            IQueryable<User> output = dbSet.Include(u=>u.UserAccount).OrderBy(u=>u.Id);

            if (search.AuthoritySpecifier == Access.BusinessAccount)
            {
                output = output.Where(u=>u.UserAccount.AccessLevel==Access.BusinessAccount && u.Id!=token_holder);
            }

            if (!string.IsNullOrWhiteSpace(search.UserName))
            {
                output = output.Where(u=>u.UserName!.ToLower().StartsWith(search.UserName.ToLower()));
            }

            if (search.EmployedBy != null)
            {
                if (search.IncludeExclude)
                {
                    output = output.Where(u=> dbContext.EmployeeRecords.Any(e=>e.UserId==u.Id && e.FranchiseId==search.EmployedBy));
                }            
                else
                {
                    output = output.Where(u=> !dbContext.EmployeeRecords.Any(e=>e.UserId==u.Id && e.FranchiseId==search.EmployedBy));
                }
            }
            return Task.FromResult(output);
        }

        public override async Task<ServiceOutput<UserResponseDTO>> GetById(Guid session,Guid token_holder, Guid id, Access authorization_level, FileScope fileScope = FileScope.Invalid)
        {
            UserResponseDTO? output = UserResponseDTO.FromEntity(await dbSet.Include(u=>u.UserAccount).FirstOrDefaultAsync(u=>u.Id==id));

            if (output == null) 
            {      
                return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotFound, "No user with this ID exists.");                 
            }

         
            if (authorization_level == Access.BusinessAccount)
            {
                IQueryable<Guid> records = dbContext.EmployeeRecords.Where(e=>e.UserId==token_holder).Select(e=>e.FranchiseId);
                List<Franchise> workplaces =  await dbContext.Franchises.Include(f=>f.Facilities).Include(f=>f.ShelteredAnimals).Where(f=>records.Contains(f.Id)||f.OwnerId==token_holder).OrderBy(w=>w.Id).ToListAsync();
                output.Workplaces=workplaces.Select(w=>FranchiseResponseDTO.FromEntity(w,w.OwnerId==token_holder)!).ToList();
              
                List<Guid> workplace_ids = workplaces.Select(w=>w.Id).ToList();
                output.Notifications = await dbContext.Notifications.Where(n=>n.UserId==token_holder || (n.FranchiseId!=null && workplace_ids.Contains(n.FranchiseId.Value!))).Select(n=>NotificationSubDTO.FromEntity(n)!).ToListAsync();
                
            }
            else if(authorization_level==Access.User)
            {
                List<Individual>individuals = await dbContext.IndividualAnimals.Include(i=>i.AnimalBreed).ThenInclude(b=>b.AnimalKind).Include(i=>i.MedicalRecord).Where(i=>i.Owned && i.OwnerId==token_holder).ToListAsync();
                List<MedicalProcedureSpecification> specifications = await dbContext.MedicalProcedureSpecifications.Include(m=>m.MedicalProcedure).ToListAsync();


                output.Notes=new();
                output.Notes.Add(await recommender.ShoppingList(dbContext,token_holder));
                foreach(Individual ind in individuals)
                {
                    output.Notes.AddRange(await recommender.AddNotesToPet(dbContext,ind,specifications));
                }
                output.Notifications = await dbContext.Notifications.Include(n=>n.RelevantListing).Where(n=>n.UserId==token_holder && (n.ListingId==null||(n.RelevantListing.Approved && n.RelevantListing.Visible))).Select(n=>NotificationSubDTO.FromEntity(n)!).ToListAsync();
                output.UserWishlist = await dbContext.Wishlists.Where(w=>w.UserId==output.Id).Select(w=>w.Term).ToListAsync();
                output.UserSupplies= await dbContext.SupplyRecords.Where(s=>s.UserId==token_holder).Select(s=>SuppliesSubDTO.FromEntity(s)!).ToListAsync();
                output.OwnedAnimals= individuals.Select(i=>IndividualResponseDTO.FromEntity(i)!).ToList();
            }           
            
            return ServiceOutput<UserResponseDTO>.Success(output);
        }

        public async Task<ServiceOutput<Guid>> GetUserState(Guid token_holder)
        {
            User? usr = await dbSet.FindAsync(token_holder);
            if(usr==null){return ServiceOutput<Guid>.Error(HttpCode.NotFound,"No user with this ID exists.");}
            return ServiceOutput<Guid>.Success(usr.UserState);
        }

        public async Task<ServiceOutput<List<AnnouncementSubDTO>>> GetAnnouncements(Access role)
        {
            IQueryable<Announcement> query = dbContext.Announcements;

            if (role == Access.User)
            {
                query=query.Where(a=>a.UserVisible);
            }
            else if (role == Access.BusinessAccount)
            {
                query=query.Where(a=>a.BusinessVisible);
            }

            List<Announcement> list = await query.ToListAsync();

            return ServiceOutput<List<AnnouncementSubDTO>>.Success(list.Select(e=> AnnouncementSubDTO.FromEntity(e)!).ToList());
            
        }

        public async Task<ServiceOutput<List<ReportResponseSubDTO>>> GetReports()
        {
            
            List<Report> list = await dbContext.Reports.ToListAsync();

            return ServiceOutput<List<ReportResponseSubDTO>>.Success(list.Select(e=> ReportResponseSubDTO.FromEntity(e)!).ToList());
            
        }


        public override async Task<ServiceOutput<UserResponseDTO>> Put(Guid session,Guid token_holder,UserRequestDTO ent)
        {

            User? current = await dbContext.Users.FindAsync(ent.Id);

            if (current != null)
            {
            await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        current.CurrentVersion=ent.CurrentVersion;
                        current.UserName = ent.UserName;
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();

                        return ServiceOutput<UserResponseDTO>.Success(UserResponseDTO.FromEntity(current));
                        
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<UserResponseDTO>.FromException(ex,logger);
                    }
                }

              

            }

            return ServiceOutput<UserResponseDTO>.Error(HttpCode.NotFound,"No user with this ID exists.");

        }

        public override Task<ServiceOutput<UserResponseDTO>> Post(Guid session,Guid token_holder,UserRequestDTO ent)
        {
            return Task.FromResult(ServiceOutput<UserResponseDTO>.Error(HttpCode.NotImplemented,"Illegal endpoint."));
        }

        public async Task<ServiceOutput<string>> SetEmployee(Guid caller_id, Guid usr_id, Guid franchise_id, bool add_remove)
        {

            await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync(IsolationLevel.Serializable))
            {

                try
                {
                    User? usr =  await dbContext.Users.Include(u=>u.UserAccount).FirstOrDefaultAsync(u=>u.Id==usr_id);
                    User? owner = await dbContext.Users.FindAsync(caller_id);
                    Franchise? franchise = await dbContext.Franchises.FindAsync(franchise_id);
                    EmployeeRecord? record = await dbContext.EmployeeRecords.FirstOrDefaultAsync(r=>r.UserId==usr_id && r.FranchiseId==franchise_id);

                    if(usr==null || owner==null || franchise==null || usr.UserAccount==null)
                    {
                        
                        return ServiceOutput<string>.Error(HttpCode.NotFound,"One or more resources needed for this operation are missing.");
                    }

                    if (add_remove)
                    {
                        if (franchise.OwnerId != owner.Id)
                        {
                            
                            return ServiceOutput<string>.Error(HttpCode.Forbidden,"The token holder does not own the specified franchise.");
                        }

                        if (usr.UserAccount.AccessLevel != Access.BusinessAccount)
                        {
                            
                            return ServiceOutput<string>.Error(HttpCode.BadRequest,"The specified user is not eligible to be an employee.");
                        }

                        if(caller_id == usr_id)
                        {
                         
                            return ServiceOutput<string>.Error(HttpCode.BadRequest,"The owner of a franchise is already considered an employee.");
                        }

                        if (record == null)
                        {
                            EmployeeRecord newRecord = new EmployeeRecord
                            {
                                UserId = usr_id,
                                FranchiseId = franchise_id,                       
                            };

                            usr.UserState=Guid.NewGuid();

                            await dbContext.EmployeeRecords.AddAsync(newRecord);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                        }

                        return ServiceOutput<string>.Success("Employee hired successfully.");
                    }
                    else
                    {

                        if (franchise.OwnerId == usr_id)
                        {
                           
                            return ServiceOutput<string>.Error(HttpCode.BadRequest,"The owner of a franchise cannot remove themselves from the employee list.");
                        }

                        if (franchise.OwnerId != owner.Id && owner.Id!=usr_id)
                        {
                           
                            return ServiceOutput<string>.Error(HttpCode.Forbidden,"You are not allowed to perform this operation.");
                        }

                        if(record!=null)
                        {
                            dbContext.EmployeeRecords.Remove(record);     

                            usr.UserState=Guid.NewGuid();
                       
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                        }

                        return ServiceOutput<string>.Success("Employee removed successfully.");
                    }
                   
                            
                }
                catch(Exception ex)
                {
                    
                    await tx.RollbackAsync();
                    return ServiceOutput<string>.FromException(ex,logger);
                }


            }


        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, UserRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"Request validation failure.");
            }

            if (resource.Id != token_holder)
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

        public override Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {                   
            if(resourceId!=token_holder)
            {
                return Task.FromResult(ServiceOutput<object>.Error(HttpCode.Forbidden,"Token does not belong to user."));
            }

            return Task.FromResult(ServiceOutput<object>.Success(null,HttpCode.NoContent));
        }



        public async Task<ServiceOutput<string>> SetWishlistTerm(Guid usr_id, string term, bool add_remove)
        {
            term = term.ToLowerInvariant();
            Wishlist? existing = await dbContext.Wishlists.FirstOrDefaultAsync(w=>w.UserId==usr_id && w.Term==term);


            if (add_remove)
            {
                if(existing == null)
                {
                    Wishlist newEntry = new Wishlist
                    {
                        UserId = usr_id,
                        Term = term
                    };

                    await dbContext.Wishlists.AddAsync(newEntry);
                    await dbContext.SaveChangesAsync();
                }
                return ServiceOutput<string>.Success("Term added to wishlist.");
            }
            else
            {
                if (existing != null)
                {
                await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                    {
                        try{
                            await existing.StageDeletion<Wishlist>(dbContext,dbContext.Wishlists);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                        }
                        catch(Exception ex){await tx.RollbackAsync(); return ServiceOutput<string>.FromException(ex,logger);}
                    }
                }
                return ServiceOutput<string>.Success("Term removed from wishlist.");
            }

            
        }


        public async Task<ServiceOutput<AnnouncementSubDTO>> AddAnnouncement(string body, bool user_visible, bool business_visible, int expiry)
        {
            if (string.IsNullOrWhiteSpace(body))
            {
                return ServiceOutput<AnnouncementSubDTO>.Error(HttpCode.BadRequest,"Announcement body cannot be empty.");
            }

            Announcement? existing = await dbContext.Announcements.FirstOrDefaultAsync(a=>a.Body.ToLower()==body.ToLower() && a.UserVisible==user_visible && a.BusinessVisible==business_visible);
            if (existing != null)
            {
                existing.Expiry = DateTime.UtcNow.AddDays(expiry);             
                await dbContext.SaveChangesAsync();
                StaticDataVersionHolder.AnnouncementVersion=Guid.NewGuid();
                return ServiceOutput<AnnouncementSubDTO>.Success(AnnouncementSubDTO.FromEntity(existing));
            }
           
            Announcement newAnnouncement = new Announcement
            {
                Body = body,
                UserVisible = user_visible,
                BusinessVisible = business_visible,
                Expiry = DateTime.UtcNow.AddDays(expiry)
            };

            try
            {
                await dbContext.Announcements.AddAsync(newAnnouncement);
                await dbContext.SaveChangesAsync();
            }
            catch(Exception ex)
            {
                return ServiceOutput<AnnouncementSubDTO>.FromException(ex,logger);
            }

            StaticDataVersionHolder.AnnouncementVersion=Guid.NewGuid();
            return ServiceOutput<AnnouncementSubDTO>.Success(AnnouncementSubDTO.FromEntity(newAnnouncement),HttpCode.Created);
        }


        public async Task<ServiceOutput<string>> RemoveAnnouncement(Guid announcement_id)
        {
            Announcement? existing = await dbContext.Announcements.FindAsync(announcement_id);

            if (existing != null)
            {
            await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {

                    try
                    {
                        await existing.StageDeletion<Announcement>(dbContext,dbContext.Announcements);
                        await dbContext.SaveChangesAsync();
                        StaticDataVersionHolder.AnnouncementVersion=Guid.NewGuid();
                        await tx.CommitAsync();
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<string>.FromException(ex,logger);
                    }

                }
                
            }

            return ServiceOutput<string>.Success("Announcement removed successfully.");
        }

        public async Task<ServiceOutput<NotificationSubDTO>> AddNotification(Guid token_holder,Access auth, string title,string body,Guid userId,Guid? franchiseId,Guid? listingId,int expiry)
        {
            if (string.IsNullOrWhiteSpace(title) || string.IsNullOrWhiteSpace(body))
            {
                return ServiceOutput<NotificationSubDTO>.Error(HttpCode.BadRequest,"Notification title and body cannot be empty.");
            }

            User? usr = await dbSet.FindAsync(userId);
            if (usr == null)
            {
                return ServiceOutput<NotificationSubDTO>.Error(HttpCode.NotFound,"The specified user does not exist.");
            }
            

            Franchise? franch = null;

            if (franchiseId != null)
            {
                franch = await dbContext.Franchises.FindAsync(franchiseId);

                if (franch == null)
                {
                    return ServiceOutput<NotificationSubDTO>.Error(HttpCode.NotFound,"Could not find specified franchise.");
                }
            }


            if(auth==Access.BusinessAccount && (franch == null||franch.OwnerId!=token_holder))
            {
                return ServiceOutput<NotificationSubDTO>.Error(HttpCode.NotFound,"You do not own a franchise with the provided ID.");
            }
            


            await using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync()){

                try
                {
                    Notification notif = new();

                    Notification? existing = await dbContext.Notifications
                        .FirstOrDefaultAsync(n =>
                            n.UserId == userId &&
                            n.ListingId == listingId &&
                            n.FranchiseId == franchiseId &&
                            n.Title.ToLower() == title.ToLower() &&
                            n.Body.ToLower() == body.ToLower()
                        );

                    if (existing != null)
                    {
                        existing.Expiry = DateTime.UtcNow.AddDays(expiry);

                        notif = existing;
                        
                    }
                    else{

                        Notification newNotification = new()
                        {
                            Title = title,
                            Body = body,
                            UserId = userId,
                            ListingId = listingId,
                            FranchiseId = franchiseId,
                            Expiry = DateTime.UtcNow.AddDays(expiry)
                        };

                        await dbContext.Notifications.AddAsync(newNotification);

                        notif= newNotification;
                    }

                  

                    if (franch != null)
                    {
                        
                            
                        List<User> emp = await dbContext.Users.Where(u=> (dbContext.Franchises.Any(f=>f.Id==franchiseId && f.OwnerId==u.Id)||dbContext.EmployeeRecords.Any(e=>e.UserId==u.Id&&e.FranchiseId==franchiseId))).ToListAsync();

                        foreach(User e in emp)
                        {
                            e.UserState=Guid.NewGuid();
                        }

                    }

                    await dbContext.SaveChangesAsync();
                    await tx.CommitAsync();

                    HttpCode code = (existing!=null)? HttpCode.OK:HttpCode.Created;

                    return ServiceOutput<NotificationSubDTO>.Success(NotificationSubDTO.FromEntity(notif),code);
                }
                catch (Exception ex)
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<NotificationSubDTO>.FromException(ex,logger);
                }

            }
        }

        public async Task<ServiceOutput<string>> RemoveNotification(Guid notification_id)
        {
            Notification? existing = await dbContext.Notifications.FindAsync(notification_id);

            if (existing != null)
            {

            await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        await existing.StageDeletion<Notification>(dbContext,dbContext.Notifications);
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<string>.FromException(ex,logger);
                    }
                }
                
            }

            return ServiceOutput<string>.Success("Notification removed successfully.");
        }
       
    }
}
