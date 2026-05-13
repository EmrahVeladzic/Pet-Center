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
using Microsoft.Extensions.Logging;
using PetCenterModels.ModelUtils;


namespace PetCenterServices.Services
{
    public class FormService : AlbumIncludingService<Form,FormSearchObject,FormDTO,FormDTO,ImageDTO,Image,ImageMetadata>, IFormService    
    {
       

        public FormService(PetCenterDBContext ctx,ILoggerFactory _logger) : base(ctx,_logger)
        {
            dbSet = ctx.Forms;
            
        }

        protected override Task<IQueryable<Form>> Filter(Guid token_holder, FormSearchObject search)
        {
            
            IQueryable<Form> query = WithAlbum().Include(f=>f.Entries).OrderBy(f=>f.Id);

            if (search.AuthoritySpecifier == Access.Admin)
            {
                query=query.Where(f=>f.Album.Reserved>0);
                search.FileRW=FileScope.ReadOnly;
            }

            else
            {
                query=query.Where(f=>f.UserId==token_holder);
                search.FileRW=FileScope.Write;
            }


            return Task.FromResult<IQueryable<Form>>(query);
             
        }       

        public override async Task<ServiceOutput<FormDTO>> Post(Guid token_holder, FormDTO resource)
        {
            Form? ent = resource.ToEntity();

            if(ent!=null){

                await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        ent.AlbumId = await CreateAlbum(token_holder,dbContext,ent.AlbumCapacity);
                        await dbSet.AddAsync(ent);
                        await dbContext.SaveChangesAsync();
                        foreach(FormEntrySubDTO entry in resource.Entries)
                        {
                            entry.FormId=ent.Id;
                            await dbContext.AddAsync(entry.ToEntity()!);
                        }
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                        return ServiceOutput<FormDTO>.Success(FormDTO.FromEntity(ent,Crypto.GenerateFileToken("",Purpose,FileScope.Write,ent.AlbumId)),HttpCode.Created);
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<FormDTO>.FromException(ex,logger);
                    }
                }

                   
            }   

            return ServiceOutput<FormDTO>.Error(HttpCode.NotFound,"Internal server error."); 
        }

        public override async Task<ServiceOutput<FormDTO>> Put(Guid token_holder, FormDTO resource)
        {
            Form? ent = await dbSet.FirstOrDefaultAsync(f=>f.Id==resource.Id && f.UserId==token_holder);

            if(ent!=null){

                ent.DefaultContact=resource.DefaultContact;
                ent.FranchiseName=resource.FranchiseName;

                await dbContext.SaveChangesAsync();
                return ServiceOutput<FormDTO>.Success(FormDTO.FromEntity(ent));
                   
            }   

            return ServiceOutput<FormDTO>.Error(HttpCode.NotFound,"This form does not exist."); 
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, FormDTO resource)
        {
            if (!ModelValidationUtils.ValidateContact(resource.DefaultContact) || string.IsNullOrWhiteSpace(resource.FranchiseName))
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"You need to provide a valid contact and the name of your franchise.");
            }

            Form? frm = await dbSet.FirstOrDefaultAsync(f=>f.Id==resource.Id&&f.UserId==token_holder);
            if (frm == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"Could not find the specified form.");
            }
            return ServiceOutput<object>.Success(null);
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
            await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
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
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<object>.FromException(ex,logger);
                    }

                }
            }
            
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }

       
}
