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
    public class CategoryService : BaseCRUDService<Category,CategorySearchObject,CategoryDTO,CategoryDTO>, ICategoryService    
    {

        public CategoryService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Categories;
        }

        protected override  Task<IQueryable<Category>> Filter(Guid token_holder, CategorySearchObject search)
        {
            return Task.FromResult<IQueryable<Category>>( dbSet.Include(c=>c.UsageSpecifics).OrderBy(c=>c.Id));
            
        }

        public override async Task<ServiceOutput<CategoryDTO>> Put(Guid token_holder, CategoryDTO req)
        {
            
            Category? ent = await dbSet.FindAsync(req.Id);

            if (ent != null)
            {

               
                Category? overwrite = req.ToEntity();
                    
                if (overwrite != null)
                {


                    using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            if(ent.Consumable==true && req.Consumable == false)
                            {
                                if(await dbContext.UsageEstimates.Where(u=>u.CategoryId==ent.Id).ToArrayAsync() is Usage[] u){dbContext.UsageEstimates.RemoveRange(u);}
                                if(await dbContext.SupplyRecords.Where(s=>s.CategoryId==ent.Id).ToArrayAsync() is Supplies[] s){dbContext.SupplyRecords.RemoveRange(s);}
                                await dbContext.SaveChangesAsync();
                            }
       
                            dbSet.Entry(ent).CurrentValues.SetValues(overwrite);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                            return ServiceOutput<CategoryDTO>.Success(CategoryDTO.FromEntity(ent));
                               
                        }
                        catch
                        {
                            await tx.RollbackAsync();
                            return ServiceOutput<CategoryDTO>.Error(HttpCode.InternalError, "Internal server error.");
                        }
                    }



                }
                    

            }

            return ServiceOutput<CategoryDTO>.Error(HttpCode.NotFound,"No resource with this ID exists.");
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, CategoryDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(c=>c.Title.ToLower()==resource.Title.ToLower()))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A category with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, CategoryDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            Category? cat = await dbSet.FindAsync(resource.Id);
            if (cat == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"This category does not exist.");
            }
            if(await dbSet.AnyAsync(c=>c.Title.ToLower()==resource.Title.ToLower() && c.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A category with this title already exists.");
            }
            
            return ServiceOutput<object>.Success(null,HttpCode.OK);
          
        }

        public override  Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {           
            return Task.FromResult<ServiceOutput<object>>(ServiceOutput<object>.Success(null,HttpCode.OK));
        }

        public async Task<ServiceOutput<SuppliesSubDTO>> TrackSupplies(Guid user_id, Guid ConsumableId, Guid KindId, int InitialMass)
        {
            if (InitialMass < 0)
            {
                return ServiceOutput<SuppliesSubDTO>.Error(HttpCode.BadRequest,"Mass cannot be a negative value.");
            }
            Kind? kind = await dbContext.AnimalKinds.FindAsync(KindId);
            if (kind == null)
            {
                return ServiceOutput<SuppliesSubDTO>.Error(HttpCode.NotFound,"The selected animal kind does not exist.");
            }
            Category? category = await dbSet.FindAsync(ConsumableId);
            if (category == null)
            {
                return ServiceOutput<SuppliesSubDTO>.Error(HttpCode.NotFound,"The selected category does not exist.");
            }
            if (category.Consumable == false)
            {
                return ServiceOutput<SuppliesSubDTO>.Error(HttpCode.BadRequest,"The selected category is not a consumable.");
            }
            Supplies? supply_record = await dbContext.SupplyRecords.FirstOrDefaultAsync(s=>s.UserId==user_id && s.CategoryId == ConsumableId && s.KindId==KindId);
            try
            {
                if (supply_record == null)
                {
                    Supplies new_record = new();
                    new_record.CategoryId = ConsumableId;
                    new_record.KindId = KindId;
                    new_record.UserId = user_id;
                    new_record.MassGrams = InitialMass;
                    new_record.Evaluated = DateTime.UtcNow;
                    await dbContext.SupplyRecords.AddAsync(new_record);
                    supply_record = new_record;
                }
                else
                {                    
                    supply_record.MassGrams=InitialMass;
                    supply_record.Evaluated = DateTime.UtcNow;
                }

                await dbContext.SaveChangesAsync();
                return ServiceOutput<SuppliesSubDTO>.Success(SuppliesSubDTO.FromEntity(supply_record));

            }
            catch
            {
                return ServiceOutput<SuppliesSubDTO>.Error(HttpCode.InternalError,"Internal server error.");
            }


        }
        public async Task<ServiceOutput<object>> StopTracking(Guid user_id, Guid SupplyId)
        {
            Supplies? supply_record = await dbContext.SupplyRecords.FindAsync(SupplyId);

            if (supply_record != null)
            {
                if (supply_record.UserId != user_id)
                {
                    return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this record.");
                }

                try
                {
                    await supply_record.StageDeletion<Supplies>(dbContext,dbContext.SupplyRecords);
                    await dbContext.SaveChangesAsync();
                }
                catch
                {
                    return ServiceOutput<object>.Error(HttpCode.InternalError,"Internal server error.");
                }

                
            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }


        public async Task<ServiceOutput<UsageSubDTO>> SetUsageEstimate(Guid CategoryId, Guid KindId, AnimalScale? scale, int daily_amount)
        {
            if (daily_amount < 0)
            {
                return ServiceOutput<UsageSubDTO>.Error(HttpCode.BadRequest,"Daily usage cannot be a negative value.");
            }
            Kind? kind = await dbContext.AnimalKinds.FindAsync(KindId);
            if (kind == null)
            {
                return ServiceOutput<UsageSubDTO>.Error(HttpCode.NotFound,"The selected animal kind does not exist.");
            }
            
            Category? category = await dbSet.FindAsync(CategoryId);
            
            if (category == null)
            {
                return ServiceOutput<UsageSubDTO>.Error(HttpCode.NotFound,"The selected category does not exist.");
            }
            if (category.Consumable == false)
            {
                return ServiceOutput<UsageSubDTO>.Error(HttpCode.BadRequest,"The selected category is not a consumable.");
            }

            Usage? usage_record = await dbContext.UsageEstimates.FirstOrDefaultAsync(s=>s.CategoryId == CategoryId && s.KindId==KindId && s.ScaleSpecific==scale);
            try
            {
                if (usage_record == null)
                {
                    Usage new_record = new();
                    new_record.CategoryId = CategoryId;
                    new_record.KindId = KindId;
                    new_record.ScaleSpecific = scale;
                    new_record.AverageDailyAmountGrams=daily_amount;
                    await dbContext.UsageEstimates.AddAsync(new_record);
                    usage_record=new_record;
                }
                else
                {                    
                    usage_record.AverageDailyAmountGrams=daily_amount;
                }

                await dbContext.SaveChangesAsync();
                return ServiceOutput<UsageSubDTO>.Success(UsageSubDTO.FromEntity(usage_record));

            }
            catch
            {
                return ServiceOutput<UsageSubDTO>.Error(HttpCode.InternalError,"Internal server error.");
            }

        }

        public async Task<ServiceOutput<object>> RemoveUsageEstimate(Guid id)
        {
            Usage? usage_record = await dbContext.UsageEstimates.FindAsync(id);

            if (usage_record != null)
            {

                try
                {
                    await usage_record.StageDeletion<Usage>(dbContext,dbContext.UsageEstimates);
                    await dbContext.SaveChangesAsync();
                }
                catch
                {
                    return ServiceOutput<object>.Error(HttpCode.InternalError,"Internal server error.");
                }

            }

            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }
}
