using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;

namespace PetCenterServices.Interfaces
{
    public interface IBaseCRUDService<TEntity,TSearch> where TEntity : BaseTableEntity where TSearch : BaseSearchObject
    {

        public Task<List<TEntity>> Get(TSearch search);
        public Task<TEntity?> GetById(int id);
        public Task Post(TEntity ent);
        public Task Put(TEntity ent);
        public Task Delete(int id);


    }
}
