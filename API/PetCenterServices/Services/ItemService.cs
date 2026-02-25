using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Services
{
    public class ItemService : BaseCRUDService<Item,ItemSearchObject,ItemDTO,ItemDTO>, IItemService
    {


        public ItemService(PetCenterDBContext ctx) : base(ctx)
        {
            dbSet = ctx.Items;
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate (Guid token_holder, ItemDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"Request validation failure.");
            }
            Category? category = await dbContext.Categories.FindAsync(resource.CategoryId);
            if (category == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The selected category does not exist.");
            }
            if(category.Consumable && resource.Mass == null)
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"The selected category is a consumable, and as such requires the weight to be specified.");
            }
            return ServiceOutput<object>.Success(null);
            

        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, ItemDTO resource)
        {
            if(! await dbSet.AnyAsync(i => i.Id == resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"This item does not exist.");
            }
            
            Category? category = await dbContext.Categories.FindAsync(resource.CategoryId);
            if (category == null)
            {
                return ServiceOutput<object>.Error(HttpCode.NotFound,"The selected category does not exist.");
            }
            if(category.Consumable && resource.Mass == null)
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"The selected category is a consumable, and as such requires the weight to be specified.");
            }
            return ServiceOutput<object>.Success(null);
            
          
        }

        public override Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {       
            
            return Task.FromResult(ServiceOutput<object>.Success(null,HttpCode.NoContent));
        }


    }
}
