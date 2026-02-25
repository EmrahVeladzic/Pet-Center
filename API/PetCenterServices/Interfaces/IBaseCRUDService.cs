using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Utils;

namespace PetCenterServices.Interfaces
{
    public interface IBaseCRUDService<TEntity,TSearch,TRequest,TResponse> where TEntity : BaseTableEntity where TSearch : BaseSearchObject where TRequest : IBaseRequestDTO where TResponse: IBaseResponseDTO<TEntity,TResponse>
    {
      
        public Task<ServiceOutput<int>> Count(Guid token_holder, TSearch search);
        public Task<ServiceOutput<List<TResponse>>> Get(Guid token_holder, TSearch search);
        public Task <ServiceOutput<TResponse>> GetById(Guid token_holder, Guid id);
        public Task<ServiceOutput<TResponse>> Post(Guid token_holder,TRequest ent);
        public Task<ServiceOutput<TResponse>> Put(Guid token_holder,TRequest ent);
        public Task<ServiceOutput<object>> Delete(Guid token_holder,Guid id);
        public Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder,TRequest resource);
        public Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder,TRequest resource);        
        public Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId);

    }
}
