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
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterServices.Recommender;


namespace PetCenterServices.Services
{
    public class FormService : AlbumIncludingService<Form,FormSearchObject,FormDTO,FormDTO>, IFormService    
    {
       

        public FormService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Forms;
            
        }

        protected override Task<IQueryable<Form>> Filter(Guid token_holder, FormSearchObject search)
        {
            
            IQueryable<Form> query = WithAlbum().Include(f=>f.Entries).OrderBy(f=>f.Id);

            if (search.AuthoritySpecifier == Access.Admin)
            {
                query=query.Where(f=>f.Album.Reserved>0);
            }

            else
            {
                query=query.Where(f=>f.UserId==token_holder);
            }


            return Task.FromResult<IQueryable<Form>>(query);
             
        }       

        public override async Task<ServiceOutput<FormDTO>> Post(Guid token_holder, FormDTO resource)
        {
            Form? ent = resource.ToEntity();

            if(ent!=null){

                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        ent.AlbumId = await ImageService.CreateAlbum(token_holder,dbContext,ent.AlbumCapacity);
                        await dbSet.AddAsync(ent);
                        await dbContext.SaveChangesAsync();
                        foreach(FormEntrySubDTO entry in resource.Entries)
                        {
                            entry.FormId=ent.Id;
                            await dbContext.AddAsync(entry.ToEntity()!);
                        }
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                        return ServiceOutput<FormDTO>.Success(FormDTO.FromEntity(ent),HttpCode.Created);
                    }
                    catch
                    {
                        await tx.RollbackAsync();
                    }
                }

                   
            }   

            return ServiceOutput<FormDTO>.Error(HttpCode.InternalError,"Internal server error."); 
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, FormDTO resource)
        {
            resource.UserId = token_holder;
            if (!resource.Validate())
            {            
                return ServiceOutput<object>.Error(HttpCode.BadRequest, "DTO validation failed.");
            }
            
            if (await dbContext.Franchises.AnyAsync(f => f.OwnerId == token_holder && f.FranchiseName == resource.FranchiseName)) 
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"You already own a franchise with this name.");
            }

           
            List<FormTemplateField> templateFields = await dbContext.FormTemplateFields
            .Where(f => f.FormTemplateId == resource.FormTemplateId)
            .ToListAsync();

            HashSet<Guid> validFieldIds = templateFields
            .Select(f => f.Id)
            .ToHashSet();

            IEnumerable<Guid> requiredFieldIds = templateFields
            .Where(f => !f.Optional)
            .Select(f => f.Id);

            HashSet<Guid> entryFieldIds = resource.Entries
            .Select(e => e.FormTemplateFieldId)
            .ToHashSet();

            
            if (requiredFieldIds.Any(id => !entryFieldIds.Contains(id)))
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"One or more mandatory fields are missing.");
            }

            
            resource.Entries.RemoveAll(e => !validFieldIds.Contains(e.FormTemplateFieldId));

            return ServiceOutput<object>.Success(null);
        }

        
        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            Form? frm = await dbSet.FindAsync(resourceId);
            if(frm!=null && frm.UserId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this form.");
            }
            return ServiceOutput<object>.Success(null);
        }

        public async Task<ServiceOutput<object>> DenyForm(Guid form_id, string reason)
        {           
            Form? frm = await dbSet.FindAsync(form_id);

            if (frm != null)
            {
                if (string.IsNullOrWhiteSpace(reason))
                {
                    return ServiceOutput<object>.Error(HttpCode.BadRequest,"The reason for denying the application needs to be specified.");
                }
                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        await frm.StageDeletion<Form>(dbContext,dbSet);
                        Notification notif = new();
                        notif.Title = $"Form denial for franchise \"{frm.FranchiseName}\".";
                        notif.Body = $"Reason for denial: \"{reason}\".";
                        notif.UserId=frm.UserId;
                        await dbContext.Notifications.AddAsync(notif);
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                    }
                    catch
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<object>.Error(HttpCode.InternalError,"Internal server error.");
                    }

                }
            }
            
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }

       
}
