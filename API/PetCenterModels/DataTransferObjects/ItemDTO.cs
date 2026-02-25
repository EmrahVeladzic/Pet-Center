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
using System.Data.Common;

namespace PetCenterModels.DataTransferObjects
{

    public class ItemDTO : ISerializableRequestDTO<Item>, IBaseResponseDTO<Item,ItemDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;

        public Guid CategoryId {get; set;} = Guid.Empty;

        public Guid? KindId {get; set;} = null;

        public AnimalScale? Scale {get; set;} = null;

        public int? Mass {get; set;} = 0;

        public static ItemDTO? FromEntity(Item? entity)
        {
            if(entity==null){return null;}
            return new ItemDTO
            {
                Id = entity.Id,
                Title = entity.Title,
                CategoryId=entity.CategoryId,
                KindId=entity.TargetKind,
                Scale = entity.TargetScale,
                Mass=entity.MassGrams
            };
        }

        public Item? ToEntity()
        {
            Item item = new();
            item.Title=Title;
            item.CategoryId=CategoryId;
            item.TargetKind=KindId;
            item.TargetScale=Scale;
            item.MassGrams=Mass;

            return item;

        }
        
        
        public bool Validate()
        {
            if(KindId==null){Scale=null;}
            return !string.IsNullOrWhiteSpace(Title) && (Mass==null||Mass>=0);
        }



    }
}
