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
    public interface ILivingConditionFieldService : IBaseCRUDService<LivingConditionField,LivingConditionSearchObject,LivingConditionFieldDTO,LivingConditionFieldDTO>
    {
       public Task<ServiceOutput<LivingConditionEntrySubDTO>> AddEntry(Guid user_id, Guid field_id, bool answer);
       public Task<ServiceOutput<object>> RemoveEntry(Guid user_id, Guid entry_id);
        
    }
}