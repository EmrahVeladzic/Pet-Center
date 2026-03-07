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


namespace PetCenterServices.Services
{
    public class FormTemplateService : BaseCRUDService<FormTemplate,FormTemplateSearchObject,FormTemplateDTO,FormTemplateDTO>, IFormTemplateService    
    {

        public FormTemplateService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.FormTemplates;
        }

        protected override void Touch()
        {
            StaticDataVersionHolder.FormTemplateVersion=Guid.NewGuid();
        }

        protected override async Task<IQueryable<FormTemplate>> Filter(Guid token_holder, FormTemplateSearchObject search)
        {
            IQueryable<FormTemplate> query = await base.Filter(token_holder, search);
            query = query.Include(ft => ft.Entries);
            return query;
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, FormTemplateDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(f => f.Description.ToLower() == resource.Description.ToLower()))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A template with this description already exists.");
            }
            
            return ServiceOutput<object>.Success(null,HttpCode.OK);
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, FormTemplateDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(f => f.Description.ToLower() == resource.Description.ToLower() && f.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A template with this description already exists.");
            }

            return ServiceOutput<object>.Success(null,HttpCode.OK);
          
        }

        public override Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {           
            
            return Task.FromResult<ServiceOutput<object>>(ServiceOutput<object>.Success(null,HttpCode.OK));
        }

        public async Task<ServiceOutput<FormTemplateFieldDTO>> SetField(FormTemplateFieldDTO field)
        {
            if(!field.Validate())
            {
                return ServiceOutput<FormTemplateFieldDTO>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(!await dbSet.AnyAsync(f => f.Id == field.FormTemplateId))
            {
                return ServiceOutput<FormTemplateFieldDTO>.Error(HttpCode.NotFound,"Template does not exist.");
            } 
            if(await dbContext.FormTemplateFields.AnyAsync(ff=>ff.FormTemplateId==field.FormTemplateId && ff.Description.ToLower()==field.Description.ToLower()&& ff.Id!=field.Id))
            {
                return ServiceOutput<FormTemplateFieldDTO>.Error(HttpCode.Conflict,"Attempt to place a duplicate field.");
            }             
            FormTemplateField? templateField = await dbContext.FormTemplateFields.FindAsync(field.Id);
            if (templateField != null)
            {
                templateField.Description=field.Description;
                templateField.Optional = field.Optional;
                templateField.FormTemplateId = field.FormTemplateId;
                await dbContext.SaveChangesAsync();
                Touch();
                return ServiceOutput<FormTemplateFieldDTO>.Success(FormTemplateFieldDTO.FromEntity(templateField));
            }
            FormTemplateField entity = field.ToEntity()!;
            await dbContext.FormTemplateFields.AddAsync(entity);
            await dbContext.SaveChangesAsync();
            Touch();
            return ServiceOutput<FormTemplateFieldDTO>.Success(FormTemplateFieldDTO.FromEntity(entity));

        }

        public async Task<ServiceOutput<object>> DeleteField(Guid fieldId)
        {
            FormTemplateField? formTemplateField = await dbContext.FormTemplateFields.FindAsync(fieldId);
            if(formTemplateField!=null)
            {

                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        await formTemplateField.StageDeletion<FormTemplateField>(dbContext,dbContext.FormTemplateFields);
                        await dbContext.SaveChangesAsync();
                        await tx.CommitAsync();
                        Touch();
                    }
                    catch(Exception ex)
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<object>.FromException(ex);
                    }
                }
            }
            
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }
}
