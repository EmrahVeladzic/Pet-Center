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
    public interface IProcedureService : IBaseCRUDService<Procedure,ProcedureSearchObject,ProcedureDTO,ProcedureDTO>
    {
        
        public Task<ServiceOutput<ProcedureSpecificationSubDTO>> SetSpecification(Guid procedure_id,Guid kind_id, Guid? breed_id, bool optional, bool? sex_specific, int? age, short? interval);

        public Task<ServiceOutput<object>> RemoveSpecification(Guid specification_id);

    }
}