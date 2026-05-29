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
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Caching.Memory;


namespace PetCenterServices.Services
{
    public class KindService : BaseCRUDService<Kind,KindSearchObject,KindDTO,KindDTO>, IKindService    
    {

        private readonly IMemoryCache _cache;

        public KindService(PetCenterDBContext ctx, ILoggerFactory _logger, IMemoryCache cache) : base(ctx, _logger)
        {
            dbSet = ctx.AnimalKinds;
            _cache = cache;
        }

        

        public override async Task<ServiceOutput<int>> Count(Guid token_holder, KindSearchObject search)
        {
            string key = $"kind_count_{StaticDataVersionHolder.KindVersion}";
            if (!_cache.TryGetValue(key, out int cached))
            {
                ServiceOutput<int> result = await base.Count(token_holder, search);
                _cache.Set(key, result.Body, TimeSpan.FromHours(6));
                return result;
            }
            return ServiceOutput<int>.Success(cached);
        }

        public override async Task<ServiceOutput<List<KindDTO>>> Get(Guid token_holder, KindSearchObject search)
        {
            string key = $"kind_page_{StaticDataVersionHolder.KindVersion}_{search.Page}";
            if (!_cache.TryGetValue(key, out List<KindDTO>? cached))
            {
                ServiceOutput<List<KindDTO>> result = await base.Get(token_holder, search);
                _cache.Set(key, result.Body, TimeSpan.FromHours(6));
                return result;
            }
            return ServiceOutput<List<KindDTO>>.Success(cached!);
        }
        protected override void Touch()
        {
            StaticDataVersionHolder.KindVersion=Guid.NewGuid();
        }

        protected override Task<IQueryable<Kind>> Filter(Guid token_holder, KindSearchObject search)
        {
            IQueryable<Kind> query = dbSet.Include(k=>k.Breeds).OrderBy(k=>k.Id);
            
            return Task.FromResult(query);
        }

        public override async Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, KindDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(k=>k.Title.ToLower()==resource.Title.ToLower()))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A kind with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
            
        }

        public override async Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, KindDTO resource)
        {
            if (!resource.Validate())
            {
                return ServiceOutput<object>.Error(HttpCode.BadRequest,"DTO validation failed.");
            }
            if(await dbSet.AnyAsync(k=>k.Title.ToLower()==resource.Title.ToLower()&& k.Id!=resource.Id))
            {
                return ServiceOutput<object>.Error(HttpCode.Conflict,"A kind with this title already exists.");
            }
            return ServiceOutput<object>.Success(null,HttpCode.OK);
          
        }

        public override  Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {           
            
            return Task.FromResult(ServiceOutput<object>.Success(null,HttpCode.OK));
        }

    }
}
