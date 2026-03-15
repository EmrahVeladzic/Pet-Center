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
    public interface IIndividualService : IBaseCRUDService<Individual,IndividualSearchObject,IndividualRequestDTO,IndividualResponseDTO>
    {
        public Task<ServiceOutput<MedicalEntrySubDTO>> SetMedicalRecord(Guid token_holder, Guid animal_id, Guid procedure_id, int? days_since_procedure);

        public Task<ServiceOutput<IndividualResponseDTO>> CopyAnimal(Guid token_holder, Guid animal_id, Guid? on_behalf_of_franchise, Access authority_specifier);
        
    }
}