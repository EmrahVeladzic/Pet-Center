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
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Caching.Memory;

namespace PetCenterServices.Services
{
    public class ItemService : BaseCRUDService<Item,ItemSearchObject,ItemDTO,ItemDTO>, IItemService
    {

        private readonly IMemoryCache _cache;

        public ItemService(PetCenterDBContext ctx, ILoggerFactory _logger, IMemoryCache cache) : base(ctx, _logger)
        {
            dbSet = ctx.Items;
            _cache = cache;
        }

        public override async Task<ServiceOutput<int>> Count(Guid token_holder, ItemSearchObject search)
        {
            string key = $"item_count_{StaticDataVersionHolder.ProductVersion}";
            if (!_cache.TryGetValue(key, out int cached))
            {
                ServiceOutput<int> result = await base.Count(token_holder, search);
                _cache.Set(key, result.Body, TimeSpan.FromHours(6));
                return result;
            }
            return ServiceOutput<int>.Success(cached);
        }

        public override async Task<ServiceOutput<List<ItemDTO>>> Get(Guid token_holder, ItemSearchObject search)
        {
            string key = $"item_page_{StaticDataVersionHolder.ProductVersion}_{search.Page}";
            if (!_cache.TryGetValue(key, out List<ItemDTO>? cached))
            {
                ServiceOutput<List<ItemDTO>> result = await base.Get(token_holder, search);
                _cache.Set(key, result.Body, TimeSpan.FromHours(6));
                return result;
            }
            return ServiceOutput<List<ItemDTO>>.Success(cached!);
        }

        protected override void Touch()
        {
            StaticDataVersionHolder.ProductVersion=Guid.NewGuid();
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
