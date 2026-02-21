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

        protected override IQueryable<Category> Filter(Guid token_holder, CategorySearchObject search)
        {
            return base.Filter(token_holder, search);
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, CategoryDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(c=>c.Title.ToLowerInvariant()==resource.Title.ToLowerInvariant()))
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
            if(await dbSet.AnyAsync(c=>c.Title.ToLowerInvariant()==resource.Title.ToLowerInvariant() && c.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A category with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
          
        }

        public override async Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {           
            await Task.CompletedTask;
            return ServiceOutput<object>.Success(null,HttpCode.OK);
        }

    }
}
