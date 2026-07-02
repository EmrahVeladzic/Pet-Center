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
       

        public FormService(PetCenterDBContext ctx,ILoggerFactory _logger) : base(ctx,_logger,"FORM")
        {
            dbSet = ctx.Forms;
            
        }

        protected override Task<IQueryable<Form>> Filter(Guid token_holder, FormSearchObject search)
        {
            
            IQueryable<Form> query = WithAlbum().Include(f=>f.Entries).Include(f=>f.Evaluator).OrderBy(f=>f.Id);

            if (search.TemplateId != null)
            {
                query=query.Where(f=>f.FormTemplateId==search.TemplateId);
            }

            if (!search.ShowEvaluated)
            {
                query= query.Where(q=>q.EvaluatorContact==null);
            }

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


        public override async Task<ServiceOutput<List<FormDTO>>> Get(Guid token_holder, FormSearchObject search)
        {
            ServiceOutput<List<FormDTO>> output = await base.Get(token_holder, search);
            if (search.AuthoritySpecifier == Access.BusinessAccount && output.Body!=null)
            {
                foreach (FormDTO f in output.Body)
                {
                    f.EvalContact=null;
                }
            }
            return output;
        }

        public override async Task<ServiceOutput<FormDTO>> GetById(Guid session,Guid token_holder, Guid id, Access authorization_level, FileScope fileScope = FileScope.ReadOnly)
        {
            fileScope=FileScope.ReadOnly;

            Form? frm = await dbSet.Include(f=>f.Entries).Include(f=>f.Album).ThenInclude(a=>a.Images).FirstOrDefaultAsync(f=>f.Id==id);

            if(frm==null)
            {
                return ServiceOutput<FormDTO>.Error(HttpCode.NotFound,"No form with this ID exists.");
            }

            if(authorization_level == Access.BusinessAccount)
            {

                if (frm.UserId != token_holder)
                {
                    return ServiceOutput<FormDTO>.Error(HttpCode.Forbidden,"You do not own this form.");
                }

                fileScope= FileScope.Write;
            }

            else if(authorization_level == Access.Admin && frm.Album.Reserved == 0)
            {
               return ServiceOutput<FormDTO>.Error(HttpCode.Forbidden,"You may not evaluate forms with no images.");
            }

            FormDTO? output = FormDTO.FromEntity(frm, authorization_level==Access.BusinessAccount);

            if (output != null)
            {
                AttachTokensIfNeeded(output,fileScope,session,token_holder,Origin);
            }




            return ServiceOutput<FormDTO>.Success(output);
            

        }

        public override async Task<ServiceOutput<FormDTO>> Post(Guid session,Guid token_holder, FormDTO resource)
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
                            FormFieldEntry fieldEntry = entry.ToEntity()!;
                            fieldEntry.FormId = ent.Id;
                            await dbContext.FormFieldEntries.AddAsync(fieldEntry);
                        }

                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                        return ServiceOutput<FormDTO>.Success(FormDTO.FromEntity(ent,Crypto.GenerateFileToken("",Purpose,FileScope.Write,ent.AlbumId,session,token_holder,Origin)),HttpCode.Created);
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<FormDTO>.FromException(ex,logger);
                    }
                }

                   
            }   

            return ServiceOutput<FormDTO>.Error(HttpCode.BadRequest,"DTO corruption."); 
        }

        public override async Task<ServiceOutput<FormDTO>> Put(Guid session,Guid token_holder, FormDTO resource)
        {
            Form? ent = await dbSet.FirstOrDefaultAsync(f=>f.Id==resource.Id && f.UserId==token_holder);

            if(ent!=null){

                ent.DefaultContact=resource.DefaultContact;
                ent.FranchiseName=resource.FranchiseName;

                await dbContext.SaveChangesAsync();

                FormDTO? output = FormDTO.FromEntity(ent);

                if (output != null)
                {
                    AttachTokensIfNeeded(output,FileScope.Write,session,token_holder,Origin);
                }

                return ServiceOutput<FormDTO>.Success(output);
                   
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


            if (resource.Entries.Any(e => !validFieldIds.Contains(e.FormTemplateFieldId)))
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"One or more fields are not related to the template.");
            }



            return ServiceOutput<object>.Success(null);
        }

        
        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            Form? frm = await dbSet.FindAsync(resourceId);
            Account? acc = await dbContext.Accounts.FindAsync(token_holder);
            if(frm!=null && frm.UserId != token_holder && acc?.AccessLevel!=Access.Owner)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this form.");
            }
            return ServiceOutput<object>.Success(null);
        }

        public async Task<ServiceOutput<object>> DenyForm(Guid token_holder, Guid form_id, string reason)
        {           
            Form? frm = await dbSet.FindAsync(form_id);

            if (frm != null)
            {
                if (frm.EvaluatorContact!=null)
                {
                    return ServiceOutput<object>.Error(HttpCode.Conflict,"You may not evaluate a form twice.");
                }


                if (string.IsNullOrWhiteSpace(reason))
                {
                    return ServiceOutput<object>.Error(HttpCode.BadRequest,"The reason for denying the application needs to be specified.");
                }
                await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        
                        frm.EvaluatorId=token_holder;
                        frm.EvaluationDate=DateTime.UtcNow;
                        frm.Reason=reason;
                        frm.Status=EvaluationStatus.Denied;
                        Account? acc = await dbContext.Accounts.FindAsync(token_holder);
                        frm.EvaluatorContact=acc?.Contact;



                        Notification notif = new();
                        notif.Title = $"Form denial for franchise \"{frm.FranchiseName}\".";
                        notif.Body = $"Reason for denial: \"{reason}\".";
                        notif.UserId=frm.UserId;

                        User? usr = await dbContext.Users.FindAsync(frm.UserId);
                        if (usr != null)
                        {
                            usr.UserState=Guid.NewGuid();
                        }

                        await dbContext.Notifications.AddAsync(notif);
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();

                            logger.LogInformation(
                            "Form {form_id} denied by {EvaluatorId} ({EvaluatorContact}). Reason: {Reason}.",
                            form_id, token_holder, acc?.Contact??"[NULL]", reason
                            );

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
