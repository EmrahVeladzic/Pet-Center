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

    public class LivingConditionEntrySubDTO : IBaseResponseDTO<LivingConditionEntry, LivingConditionEntrySubDTO>
    {
        public Guid? Id {get; set;} = null;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid UserId {get; set;} = Guid.Empty;

        public Guid FieldId {get; set;} = Guid.Empty;

        public bool Answer {get; set;} = false;

        public static LivingConditionEntrySubDTO? FromEntity(LivingConditionEntry? entry)
        {
            if(entry==null){return null;}

            return new LivingConditionEntrySubDTO
            {
                Id=entry.Id,
                UserId = entry.UserId,
                FieldId = entry.LivingConditionFieldID,
                Answer = entry.Answer
            };

            

        }
    }
    public class LivingConditionFieldDTO : ISerializableRequestDTO<LivingConditionField>, IBaseResponseDTO<LivingConditionField,LivingConditionFieldDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;

        public float InvestmentEffect { get; set; } = 0.0f;
        public float TerritoryEffect { get; set; } = 0.0f;
        public float PricingEffect { get; set; } = 0.0f;
        public float LongevityEffect { get; set; } = 0.0f;
        public float CohabitationEffect { get; set; } = 0.0f;

        public LivingConditionEntrySubDTO? Entry {get; set;} = null;

        public static LivingConditionFieldDTO? FromEntity(LivingConditionField? entity)
        {
            if(entity==null){return null;}
            return new LivingConditionFieldDTO
            {
                Id = entity.Id,
                Title = entity.Title,
                InvestmentEffect=entity.InvestmentEffect,
                TerritoryEffect=entity.TerritoryEffect,
                PricingEffect=entity.PricingEffect,
                LongevityEffect=entity.LongevityEffect,
                CohabitationEffect=entity.CohabitationEffect,
                Entry = LivingConditionEntrySubDTO.FromEntity(entity.Entries.FirstOrDefault())
            };
        }

        public LivingConditionField? ToEntity()
        {
            LivingConditionField field = new();
           
            field.Title=Title;
            field.InvestmentEffect=InvestmentEffect;
            field.TerritoryEffect=TerritoryEffect;
            field.PricingEffect=PricingEffect;
            field.LongevityEffect=LongevityEffect;
            field.CohabitationEffect=CohabitationEffect;
            
            return field;
        }
        
        
        public bool Validate()
        {
            return !string.IsNullOrWhiteSpace(Title) && !((InvestmentEffect+TerritoryEffect+PricingEffect+LongevityEffect+CohabitationEffect)==0.0f);
        }



    }
}
