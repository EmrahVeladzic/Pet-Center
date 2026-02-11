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
    public class FranchiseService : BaseCRUDService<Franchise,FranchiseSearchObject,FranchiseRequestDTO,FranchiseResponseDTO>, IFranchiseService    
    {

        public FranchiseService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Franchises;
        }

        protected override IQueryable<Franchise> Filter(FranchiseSearchObject search)
        {
            IQueryable<Franchise> output = base.Filter(search);
            
            if (search.RelatedUser != null)
            {
                if (search.owner_worker)
                {
                    output = output.Where(f=>f.OwnerId==search.RelatedUser);
                }
                else
                {
                    IQueryable<Guid> records = dbContext.EmployeeRecords.Where(e=>e.UserId==search.RelatedUser).Select(e=>e.FranchiseId);
                    output = output.Where(f=>records.Contains(f.Id));
                }
               
                
            }
            return output;
        }

        public override async Task<ServiceOutput<FranchiseResponseDTO>> Post(Guid? token_holder, FranchiseRequestDTO req)
        {
            Form? frm = await dbContext.Forms.FindAsync(req.CreationFormId);
            if (frm == null)
            {
                return ServiceOutput<FranchiseResponseDTO>.Error(HttpCode.NotFound,"No form to base franchise on.");
            } 

            Franchise franch = new();

            franch.Contact=frm.DefaultContact;
            franch.FranchiseName = frm.FranchiseName;


            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {                   
                    await dbSet.AddAsync(franch);
                    await dbContext.SaveChangesAsync();
                    await tx.CommitAsync();
                }
                catch 
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<FranchiseResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");
                }
            }

            

            return ServiceOutput<FranchiseResponseDTO>.Success(FranchiseResponseDTO.FromEntity(franch),HttpCode.Created);

        }

        public override async Task<ServiceOutput<FranchiseResponseDTO>> Put(Guid? token_holder, FranchiseRequestDTO req)
        {
            Franchise? franch = await dbSet.FindAsync(req.Id);
            if(franch==null){return ServiceOutput<FranchiseResponseDTO>.Error(HttpCode.NotFound,"Franchise does not exist.");}
            franch.Contact = req.Contact;
            franch.FranchiseName = req.FranchiseName;

            using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
            {
                try
                {
                    await dbContext.SaveChangesAsync();
                    await tx.CommitAsync();
                }
                catch 
                {
                    await tx.RollbackAsync();
                    return ServiceOutput<FranchiseResponseDTO>.Error(HttpCode.InternalError,"Internal server error.");
                }
            }

            return ServiceOutput<FranchiseResponseDTO>.Success(FranchiseResponseDTO.FromEntity(franch),HttpCode.OK);

        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid? token_holder, FranchiseRequestDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
         
            Franchise? fr = await dbSet.FindAsync(resource.Id);
            if(fr == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested franchise does not exist.");

            }
            if (fr.OwnerId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this franchise.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);

        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid? token_holder, Guid resourceId)
        {
            Franchise? fr = await dbSet.FindAsync(resourceId);
            if(fr == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The requested franchise does not exist.");

            }
            if (fr.OwnerId != token_holder)
            {
                return ServiceOutput<object>.Error(HttpCode.Forbidden,"You do not own this franchise.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.NoContent);
        }

    }
}
