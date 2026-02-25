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
    public interface ICategoryService : IBaseCRUDService<Category,CategorySearchObject,CategoryDTO,CategoryDTO>
    {
        public Task<ServiceOutput<SuppliesSubDTO>> TrackSupplies(Guid user_id, Guid ConsumableId, Guid KindId, int InitialMass);
        public Task<ServiceOutput<object>> StopTracking(Guid user_id, Guid SupplyId);
        
        public Task<ServiceOutput<UsageSubDTO>> SetUsageEstimate(Guid CategoryId, Guid KindId, AnimalScale? scale, int daily_amount);
        public Task<ServiceOutput<object>> RemoveUsageEstimate(Guid id);
        
    }
}