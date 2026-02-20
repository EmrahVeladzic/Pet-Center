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

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;


        public static KindDTO? FromEntity(Kind? entity)
        {
            if(entity==null){return null;}
            return new KindDTO
            {
                Id = entity.Id,
                Title = entity.Title
            };
        }

        public Kind? ToEntity()
        {
            Kind kind = new();
           
            kind.Title=Title;
            return kind;
        }
        
        
        public bool Validate()
        {
            return !string.IsNullOrWhiteSpace(Title);
        }



    }
}
