using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;


namespace PetCenterModels.DataTransferObjects
{
    public class MedicalEntrySubDTO : IBaseResponseDTO<MedicalRecordEntry, MedicalEntrySubDTO>
    {
        public Guid? Id {get; set;}
        public List<NoteSubDTO>? Notes {get; set;}

        public DateTime DatePerformed {get; set;} = DateTime.UtcNow;

        public Guid ProcedureId {get; set;} = Guid.Empty;

        public Guid AnimalId{get; set;} = Guid.Empty;

        public static MedicalEntrySubDTO? FromEntity(MedicalRecordEntry? ent)
        {
            if(ent==null){return null;}
            return new MedicalEntrySubDTO
            {
                Id=ent.Id,
                DatePerformed=ent.DatePerformed,
                ProcedureId=ent.ProcedureId,
                AnimalId=ent.AnimalId
            };
        }
    }
    public class IndividualResponseDTO : IBaseResponseDTO<Individual,IndividualResponseDTO>
    {        

        public Guid? Id {get; set;}

        public Guid Identity {get; set;} = Guid.Empty;
        public string Name {get; set;} = string.Empty;

        public Guid BreedId {get; set;} = Guid.Empty;

        public bool Sex {get; set;}

        public DateTime BirthDate {get; set;} = DateTime.UtcNow;

        public List<NoteSubDTO>? Notes {get; set;}

        public List<MedicalEntrySubDTO> MedicalRecord {get; set;} = new();

        public static IndividualResponseDTO? FromEntity(Individual? ind)
        {
            if(ind==null){return null;}

            return new IndividualResponseDTO
            {
                Id = ind.Id,
                Identity=ind.AnimalIdentity,
                Name = ind.Name,
                BreedId=ind.BreedId,
                Sex=ind.Sex,
                BirthDate=ind.BirthDate,
                MedicalRecord = ind.MedicalRecord.Select(m=>MedicalEntrySubDTO.FromEntity(m)!).ToList()
            };
        }
    }
}
