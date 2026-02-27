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
    public class IndividualService : BaseCRUDService<Individual,IndividualSearchObject,IndividualRequestDTO,IndividualResponseDTO>, IIndividualService    
    {
       
        private readonly IRecommenderSystem recommender;

        public IndividualService(PetCenterDBContext ctx,IRecommenderSystem rec) : base(ctx)
        {
            dbSet = ctx.IndividualAnimals;
            recommender=rec;   
        }

        protected override async Task<IQueryable<Individual>> Filter(Guid token_holder, IndividualSearchObject search)
        {
            
            IQueryable<Individual> query = dbSet.Include(i=>i.MedicalRecord).OrderBy(f=>f.Id);

            if (search.AuthoritySpecifier == Access.BusinessAccount && search.from_franchise!=null && await FranchiseService.IsEmployeeOfFranchise(dbContext,token_holder,search.from_franchise.Value))
            {
                query = query.Where(i=>i.ShelterId!=search.from_franchise);
                
            }

            else
            {
                query = query.Where(i=>i.OwnerId==token_holder);
            }


            return query;
             
        }

        public override async Task<ServiceOutput<List<IndividualResponseDTO>>> Get(Guid token_holder, IndividualSearchObject search)
        {
            IQueryable<Individual> query = await Filter(token_holder,search);
            List<Individual> entities = await query.Skip(search.Page*search.PageSize).Take(search.PageSize).ToListAsync();
            List<IndividualResponseDTO> output = entities.Select(e=>IndividualResponseDTO.FromEntity(e)!).ToList();
            if (search.AuthoritySpecifier == Access.User && entities.Count==output.Count)
            {
                for(int i= 0; i<entities.Count; i++)
                {
                    output[i].Notes=await recommender.AddNotesToPet(dbContext,entities[i]);
                }
            }
            return ServiceOutput<List<IndividualResponseDTO>>.Success(output);
        }

        public override async Task<ServiceOutput<IndividualResponseDTO>> Put(Guid token_holder, IndividualRequestDTO req)
        {
            Individual? current = await dbSet.FindAsync(req.Id);
            if(current==null)
            {
                return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.NotFound,"The specified animal does not exist.");
            }

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {

                try
                {
                    current.BreedId=req.BreedId;
                    current.Name=req.Name;
                    current.Sex=req.Sex;
                    current.BirthDate=req.BirthDate;
                    await dbContext.SaveChangesAsync();
                    await tx.CommitAsync();
                    return ServiceOutput<IndividualResponseDTO>.Success(IndividualResponseDTO.FromEntity(current));
                }
                catch
                {
                    await tx.RollbackAsync();                    
                }


            }

            
            return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");
                        
        }

      
        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, IndividualRequestDTO resource)
        {
            if (resource.AuthoritySpecifier == Access.User)
            {
                resource.OwnerId=token_holder;
            }
            else
            {
                if (resource.ShelterId == null)
                {
                    return ServiceOutput<object>.Error(HttpCode.BadRequest, "Employees need to provide the franchise ID to add sheltered animals.");
                }
                if (! await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, resource.ShelterId.Value))
                {
                   return ServiceOutput<object>.Error(HttpCode.Forbidden, "You are not employed by this franchise."); 
                }
            }
            if (!resource.Validate())
            {            
                return ServiceOutput<object>.Error(HttpCode.BadRequest, "DTO validation failed.");
            }
            if(! await dbContext.AnimalBreeds.AnyAsync(b => b.Id == resource.BreedId)){
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The specified animal breed does not exist.");
            }
            
        
            return ServiceOutput<object>.Success(null);
        }


        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, IndividualRequestDTO resource)
        {

            if(!await dbSet.AnyAsync(i => i.Id == resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The specified animal does not exist.");
            }

            if (resource.AuthoritySpecifier == Access.User)
            {
                resource.OwnerId=token_holder;
            }
            else
            {
                if (resource.ShelterId == null)
                {
                    return ServiceOutput<object>.Error(HttpCode.BadRequest, "Employees need to provide the franchise ID to add sheltered animals.");
                }
                if (! await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, resource.ShelterId.Value))
                {
                   return ServiceOutput<object>.Error(HttpCode.Forbidden, "You are not employed by this franchise."); 
                }
            }
            if (!resource.Validate())
            {            
                return ServiceOutput<object>.Error(HttpCode.BadRequest, "DTO validation failed.");
            }
            if(! await dbContext.AnimalBreeds.AnyAsync(b => b.Id == resource.BreedId)){
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The specified animal breed does not exist.");
            }
            
        
            return ServiceOutput<object>.Success(null);
        }


        
        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            Individual? ind = await dbSet.FindAsync(resourceId);

            if (ind != null)
            {
                if (ind.Owned)
                {
                    if (ind.OwnerId != token_holder)
                    {
                        return ServiceOutput<object>.Error(HttpCode.Forbidden,"You are not authorized to perform this action.");
                    }
                }
                else
                {
                    if (ind.ShelterId == null)
                    {
                        return ServiceOutput<object>.Error(HttpCode.InternalError,"Internal server error.");
                    }


                    if (!await FranchiseService.IsEmployeeOfFranchise(dbContext,token_holder,ind.ShelterId.Value))
                    {
                        return ServiceOutput<object>.Error(HttpCode.Forbidden,"You are not authorized to perform this action.");
                    } 
                }


            }


            return ServiceOutput<object>.Success(null);
            
        }


        public async Task<ServiceOutput<MedicalEntrySubDTO>> SetMedicalRecord(Guid token_holder, Guid animal_id, Guid procedure_id, int? days_since_procedure)
        {
            Individual? individual = await dbContext.IndividualAnimals.FindAsync(animal_id);

            if (individual == null)
            {
                if (days_since_procedure == null)
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Success(null,HttpCode.NoContent);
                }
                else
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Error(HttpCode.NotFound,"The selected animal does not exist.");
                }

            }
            if (individual.Owned)
            {
                if (individual.OwnerId == null)
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Error(HttpCode.InternalError,"Internal server error.");
                }
                if (individual.OwnerId != token_holder)
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Error(HttpCode.Forbidden,"You lack the permission to perform this action.");
                }
            }
            else
            {
                if (individual.ShelterId == null)
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Error(HttpCode.InternalError,"Internal server error.");
                }
                if(!await FranchiseService.IsEmployeeOfFranchise(dbContext, token_holder, individual.ShelterId.Value))
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Error(HttpCode.Forbidden,"You lack the permission to perform this action.");
                }
            }
            MedicalRecordEntry? medical = await dbContext.MedicalRecordEntries.FirstOrDefaultAsync(m=>m.AnimalId==animal_id && m.ProcedureId == procedure_id);
            if (medical == null)
            {
                if (days_since_procedure == null)
                {
                    return ServiceOutput<MedicalEntrySubDTO>.Success(null,HttpCode.NoContent);
                }
                else
                {
                    days_since_procedure=Math.Max((int)days_since_procedure,0);
                    days_since_procedure*=-1;
                    MedicalRecordEntry new_entry = new MedicalRecordEntry
                    {
                        AnimalId=animal_id,
                        ProcedureId=procedure_id,
                        DatePerformed=DateTime.UtcNow.AddDays((int)days_since_procedure)
                    };
                    await dbContext.MedicalRecordEntries.AddAsync(new_entry);
                    await dbContext.SaveChangesAsync();
                    return ServiceOutput<MedicalEntrySubDTO>.Success(MedicalEntrySubDTO.FromEntity(new_entry));
                }
            }
            else
            {
                if (days_since_procedure == null)
                {
                    dbContext.MedicalRecordEntries.Remove(medical);
                    await dbContext.SaveChangesAsync();
                    return ServiceOutput<MedicalEntrySubDTO>.Success(null,HttpCode.NoContent);
                }
                else
                {
                    days_since_procedure=Math.Max((int)days_since_procedure,0);
                    days_since_procedure*=-1;
                    medical.DatePerformed=DateTime.UtcNow.AddDays((int)days_since_procedure);
                    await dbContext.SaveChangesAsync();
                    return ServiceOutput<MedicalEntrySubDTO>.Success(MedicalEntrySubDTO.FromEntity(medical));
                }
            }

        }


        public async Task<ServiceOutput<IndividualResponseDTO>> CopyAnimal(Guid token_holder, Guid animal_id, Guid? on_behalf_of_franchise, Access authority_specifier)
        {
            bool as_franchise = authority_specifier==Access.BusinessAccount;

            Individual? individual_animal = await dbSet.Include(i=>i.MedicalRecord).FirstOrDefaultAsync(i=>i.Id==animal_id);
            if (individual_animal == null)
            {
                return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.NotFound,"The selected animal does not exist.");
            }

            if (as_franchise)
            {
                if (on_behalf_of_franchise == null)
                {
                    return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.BadRequest,"Employees need to provide the franchise ID to add sheltered animals.");
                }
                if (!await FranchiseService.IsEmployeeOfFranchise(dbContext,token_holder,on_behalf_of_franchise.Value))
                {
                    return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.Forbidden,"You lack the permission to perform this action.");
                }
                if(await dbSet.AnyAsync(i=>i.ShelterId==on_behalf_of_franchise && i.AnimalIdentity == individual_animal.AnimalIdentity))
                {
                    return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.Conflict,"Your franchise already shelters this animal.");
                }
            }
            else
            {
                if(await dbSet.AnyAsync(i=>i.OwnerId==token_holder && i.AnimalIdentity == individual_animal.AnimalIdentity))
                {
                    return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.Conflict,"You already own this animal.");
                }
            } 

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    Individual new_individual = new Individual
                    {
                        AnimalIdentity=individual_animal.AnimalIdentity,
                        BreedId=individual_animal.BreedId,
                        BirthDate=individual_animal.BirthDate,
                        Name=individual_animal.Name,
                        Sex=individual_animal.Sex,
                        Owned=!as_franchise,
                        OwnerId = (as_franchise)? null: token_holder,
                        ShelterId =(as_franchise)? on_behalf_of_franchise : null
                    };
                    await dbSet.AddAsync(new_individual);
                    await dbContext.SaveChangesAsync();

                    new_individual.MedicalRecord=individual_animal.MedicalRecord.Select(m=>new MedicalRecordEntry{ProcedureId=m.ProcedureId,DatePerformed=m.DatePerformed,AnimalId=new_individual.Id}).ToList();
                    
                    await dbContext.MedicalRecordEntries.AddRangeAsync(new_individual.MedicalRecord.ToArray());
                    await dbContext.SaveChangesAsync();
                    await tx.CommitAsync();
                    return ServiceOutput<IndividualResponseDTO>.Success(IndividualResponseDTO.FromEntity(new_individual));
                }
                catch
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<IndividualResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");
                }

            }
            

        }
        

    }

       
}
