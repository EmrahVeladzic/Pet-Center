using Microsoft.VisualBasic;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.SearchObjects;

namespace PetCenterModels.DataTransferObjects
{
    public class ProcedureSpecificationSubDTO : IBaseResponseDTO<MedicalProcedureSpecification, ProcedureSpecificationSubDTO>
    {
        public Guid? Id {get; set;} = null;
      
        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid ProcedureID {get; set;} = Guid.Empty;

        public Guid KindId {get; set;} = Guid.Empty;

        public Guid? BreedId {get; set;} = null;

        public bool Optional {get; set;} = true;

        public bool? SexSpecific {get; set;} = null;

        public int? ApproximateAge {get; set;} = null;

        public short? Interval {get; set;} = null;

        public static ProcedureSpecificationSubDTO? FromEntity(MedicalProcedureSpecification? entity)
        {
            if(entity==null){return null;}
            return new ProcedureSpecificationSubDTO
            {
                Id=entity.Id,
                ProcedureID=entity.ProcedureId,
                Optional=entity.Optional,
                KindId=entity.KindId,
                BreedId=entity.BreedId,
                SexSpecific=entity.SexSpecific,
                Interval=entity.IntervalDays,
                ApproximateAge=entity.ApproximateAge

            };

        }
    }

    public class ProcedureDTO : ISerializableRequestDTO<Procedure>, IBaseResponseDTO<Procedure,ProcedureDTO>
    {
       
        public Guid? Id {get; set;} = null;
      
        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Description {get; set;} = string.Empty;

        public List<ProcedureSpecificationSubDTO> Specifications {get; set;} = new();

        public static ProcedureDTO? FromEntity(Procedure? entity)
        {
            if(entity==null){return null;}
            ProcedureDTO output = new ProcedureDTO
            {
                Id = entity.Id,
                Description = entity.Description,
                Specifications = entity.Specifications.Select(s=>ProcedureSpecificationSubDTO.FromEntity(s)!).ToList()
            };

            

            return output;
        }

        public Procedure? ToEntity()
        {
            Procedure proc = new();
           
            proc.Description=Description;
            return proc;
        }
        
        
        public bool Validate()
        {
            
            return !string.IsNullOrWhiteSpace(Description);
        }



    }
}
