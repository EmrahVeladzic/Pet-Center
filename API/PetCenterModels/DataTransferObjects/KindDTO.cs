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

namespace PetCenterModels.DataTransferObjects
{
    public class KindDTO : ISerializableRequestDTO<Kind>, IBaseResponseDTO<Kind,KindDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;

        public List<BreedDTO> Breeds {get; set;} = new();


        public static KindDTO? FromEntity(Kind? entity)
        {
            if(entity==null){return null;}
            return new KindDTO
            {
                Id = entity.Id,
                CurrentVersion=entity.CurrentVersion,
                Title = entity.Title,
                Breeds=entity.Breeds.Select(b=>BreedDTO.FromEntity(b)!).ToList()

            };
        }

        public Kind? ToEntity()
        {
            Kind kind = new();
            kind.CurrentVersion = CurrentVersion;
            kind.Title=Title;
            return kind;
        }
        
        
        public bool Validate()
        {
            return !string.IsNullOrWhiteSpace(Title);
        }



    }
}
