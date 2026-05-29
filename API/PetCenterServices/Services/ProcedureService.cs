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
using Microsoft.Extensions.Caching.Memory;


namespace PetCenterServices.Services
{
    public class ProcedureService : BaseCRUDService<Procedure,ProcedureSearchObject,ProcedureDTO,ProcedureDTO>, IProcedureService    
    {
        

        private readonly IMemoryCache _cache;

        public ProcedureService(PetCenterDBContext ctx, ILoggerFactory _logger, IMemoryCache cache) : base(ctx, _logger)
        {
            dbSet = ctx.MedicalProcedures;
            _cache = cache;
        }

        public override async Task<ServiceOutput<int>> Count(Guid token_holder, ProcedureSearchObject search)
        {
            string key = $"procedure_count_{StaticDataVersionHolder.ProcedureVersion}";
            if (!_cache.TryGetValue(key, out int cached))
            {
                ServiceOutput<int> result = await base.Count(token_holder, search);
                _cache.Set(key, result.Body, TimeSpan.FromHours(6));
                return result;
            }
            return ServiceOutput<int>.Success(cached);
        }

        public override async Task<ServiceOutput<List<ProcedureDTO>>> Get(Guid token_holder, ProcedureSearchObject search)
        {
            string key = $"procedure_page_{StaticDataVersionHolder.ProcedureVersion}_{search.Page}";
            if (!_cache.TryGetValue(key, out List<ProcedureDTO>? cached))
            {
                ServiceOutput<List<ProcedureDTO>> result = await base.Get(token_holder, search);
                _cache.Set(key, result.Body, TimeSpan.FromHours(6));
                return result;
            }
            return ServiceOutput<List<ProcedureDTO>>.Success(cached!);
        }

        protected override void Touch()
        {
            StaticDataVersionHolder.ProcedureVersion=Guid.NewGuid();
        }

        protected override Task<IQueryable<Procedure>> Filter(Guid token_holder, ProcedureSearchObject search)
        {

            IQueryable<Procedure> query = dbSet.Include(p=>p.Specifications).OrderBy(p=>p.Id);
            return Task.FromResult(query);
            
        }


        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, ProcedureDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }

            if(await dbSet.AnyAsync(p => p.Description.ToLower() == resource.Description.ToLower()))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"This medical procedure is already defined.");
            }

          
            return ServiceOutput<object>.Success(null);
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, ProcedureDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }


            if(await dbSet.AnyAsync(p => p.Description.ToLower() == resource.Description.ToLower()&&p.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"This medical procedure is already defined.");
            }


           
            return ServiceOutput<object>.Success(null);
        }

        public override Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            return Task.FromResult(ServiceOutput<object>.Success(null));
        }

        public async Task<ServiceOutput<ProcedureSpecificationSubDTO>> SetSpecification(Guid procedure_id,Guid kind_id, Guid? breed_id, bool optional, bool? sex_specific, int? age, short? interval)
        {
            if(interval!=null && interval < 1)
            {
                return ServiceOutput<ProcedureSpecificationSubDTO>.Error(HttpCode.BadRequest,"The interval needs to be a valid number above 0.");
            }

            if(!await dbContext.MedicalProcedures.AnyAsync(p => p.Id == procedure_id))
            {
                return ServiceOutput<ProcedureSpecificationSubDTO>.Error(HttpCode.NotFound,"The selected procedure does not exist.");
            }
            if(!await dbContext.AnimalKinds.AnyAsync(k => k.Id == kind_id))
            {
                return ServiceOutput<ProcedureSpecificationSubDTO>.Error(HttpCode.NotFound,"The selected animal kind does not exist.");
            }
            if(breed_id!=null && !await dbContext.AnimalBreeds.AnyAsync(b => b.Id == breed_id && b.KindId==kind_id))
            {
                return ServiceOutput<ProcedureSpecificationSubDTO>.Error(HttpCode.NotFound,"The selected animal breed does not exist.");
            }

            if(breed_id==null && age == null)
            {
                return ServiceOutput<ProcedureSpecificationSubDTO>.Error(HttpCode.BadRequest,"Kind-wide exemptions for a procedure are implied by default.");
            }

            else if(breed_id!=null && age == null && ! await dbContext.MedicalProcedureSpecifications.AnyAsync(p=>p.ProcedureId==procedure_id&&p.KindId == kind_id&&p.BreedId==null))
            {
                return ServiceOutput<ProcedureSpecificationSubDTO>.Error(HttpCode.BadRequest,"This kind is already exempt from the procedure. The breed-specific exemption does not make sense.");
            }

          
            MedicalProcedureSpecification? existing = await dbContext.MedicalProcedureSpecifications.FirstOrDefaultAsync(p=>p.ProcedureId==procedure_id&&p.KindId==kind_id&&p.BreedId==breed_id&&p.SexSpecific==sex_specific);

            if (existing != null)
            {
                existing.ApproximateAge=age;
                existing.IntervalDays=interval;
                existing.Optional=optional;

                await dbContext.SaveChangesAsync();
            }

            else
            {
                MedicalProcedureSpecification new_spec = new MedicalProcedureSpecification
                {
                    KindId=kind_id,
                    ProcedureId=procedure_id,
                    BreedId=breed_id,
                    SexSpecific=sex_specific,
                    Optional=optional,
                    IntervalDays=interval,
                    ApproximateAge=age

                };

                await dbContext.MedicalProcedureSpecifications.AddAsync(new_spec);
                await dbContext.SaveChangesAsync();
                existing=new_spec;

            }

            Touch();
            
            StaticDataVersionHolder.SpecificationVersion=Guid.NewGuid();
            return ServiceOutput<ProcedureSpecificationSubDTO>.Success(ProcedureSpecificationSubDTO.FromEntity(existing));
            
        }


        public async Task<ServiceOutput<object>> RemoveSpecification(Guid specification_id)
        {
            MedicalProcedureSpecification? existing = await dbContext.MedicalProcedureSpecifications.FindAsync(specification_id);

            if (existing != null)
            {
            await using(IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {                    
                
                    try
                    {
                        await existing.StageDeletion<MedicalProcedureSpecification>(dbContext,dbContext.MedicalProcedureSpecifications);
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

            Touch();

            StaticDataVersionHolder.SpecificationVersion=Guid.NewGuid();
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }

       
}
