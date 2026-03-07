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
    public class LivingconditionFieldService : BaseCRUDService<LivingConditionField,LivingConditionSearchObject,LivingConditionFieldDTO,LivingConditionFieldDTO>, ILivingConditionFieldService    
    {

        public LivingconditionFieldService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.LivingConditionFields;
        }

        protected override void Touch()
        {
            StaticDataVersionHolder.LivingConditionVersion=Guid.NewGuid();
        }

        protected override Task<IQueryable<LivingConditionField>> Filter(Guid token_holder, LivingConditionSearchObject search)
        {
           
            IQueryable<LivingConditionField> query = dbSet.Include(l=>l.Entries.Where(e=>e.UserId==token_holder).Take(1)).OrderBy(o=>o.Id);
            return Task.FromResult(query);
        }
        
        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, LivingConditionFieldDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(l=>l.Title.ToLower()==resource.Title.ToLower()))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A living condition field with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, LivingConditionFieldDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            LivingConditionField? field = await dbSet.FindAsync(resource.Id);
            if (field == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"This living condition field does not exist.");
            }
            if(await dbSet.AnyAsync(f=>f.Title.ToLower()==resource.Title.ToLower() && f.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A living condition field with this title already exists.");
            }
            
            return ServiceOutput<object>.Success(null,HttpCode.OK);
          
        }

        public override  Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {           
            
            return Task.FromResult<ServiceOutput<object>>(ServiceOutput<object>.Success(null,HttpCode.OK));
        }

        public async Task<ServiceOutput<LivingConditionEntrySubDTO>> AddEntry(Guid user_id, Guid field_id, bool answer)
        {
            if(!await dbSet.AnyAsync(f => f.Id == field_id))
            {
                return ServiceOutput<LivingConditionEntrySubDTO>.Error(HttpCode.NotFound,"No such field exists.");
            }
           
            LivingConditionEntry? entry = await dbContext.LivingConditionEntries.FirstOrDefaultAsync(e=>e.UserId==user_id && e.LivingConditionFieldID==field_id);
            try
            {
                if (entry == null)
                {
                    LivingConditionEntry new_record = new();
                    new_record.UserId=user_id;
                    new_record.LivingConditionFieldID=field_id;
                    new_record.Answer = answer;
                   
                    await dbContext.LivingConditionEntries.AddAsync(new_record);
                    entry = new_record;
                }
                else
                {                    
                    entry.Answer=answer;
                }

                await dbContext.SaveChangesAsync();
                Touch();
                return ServiceOutput<LivingConditionEntrySubDTO>.Success(LivingConditionEntrySubDTO.FromEntity(entry));

            }
            catch(Exception ex)
            {
                return ServiceOutput<LivingConditionEntrySubDTO>.FromException(ex);
            }


        }

        public async Task<ServiceOutput<object>> RemoveEntry(Guid user_id, Guid entry_id)
        {
            LivingConditionEntry? entry = await dbContext.LivingConditionEntries.FindAsync(entry_id);

            if (entry != null)
            {
                if (entry.UserId != user_id)
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this entry.");
                }

                try
                {
                    await entry.StageDeletion<LivingConditionEntry>(dbContext,dbContext.LivingConditionEntries);
                    await dbContext.SaveChangesAsync();
                }
                catch(Exception ex)
                {
                    return ServiceOutput<object>.FromException(ex);
                }

                
            }
            Touch();
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }
}
