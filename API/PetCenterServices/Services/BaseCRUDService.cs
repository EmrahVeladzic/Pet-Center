using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Services
{
    public class BaseCRUDService<TEntity, TSearch> : IBaseCRUDService<TEntity,TSearch> where TEntity : BaseTableEntity where TSearch : BaseSearchObject
    {
        protected PetCenterDBContext dbContext;

        public BaseCRUDService(PetCenterDBContext ctx)
        {
            dbContext = ctx;
        }

        public async Task<List<TEntity>>Get(TSearch search)
        {
            await Task.CompletedTask;
            return new();
        }

        public async Task<TEntity?>GetById(int id)
        {
            await Task.CompletedTask;
            return null;
        }

        public async Task Post(TEntity ent)
        {
            await Task.CompletedTask;
        }

        public async Task Put(TEntity ent)
        {
            await Task.CompletedTask;
        }

        public async Task Delete(int id)
        {
            await Task.CompletedTask;
        }
    }
}
