using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Utils;

namespace PetCenterServices.Interfaces
{
    public interface IBaseCRUDService<TEntity,TSearch,TRequest,TResponse> where TEntity : BaseTableEntity where TSearch : BaseSearchObject where TRequest : IBaseRequestDTO where TResponse: IBaseResponseDTO
    {

        public Task<ServiceOutput<List<TResponse>>> Get(TSearch search);
        public Task <ServiceOutput<TResponse>> GetById(Guid id);
        public Task<ServiceOutput<TResponse>> Post(TRequest ent);
        public Task<ServiceOutput<TResponse>> Put(TRequest ent);
        public Task<ServiceOutput<object>> Delete(Guid id);


    }
}
