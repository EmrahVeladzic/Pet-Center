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

    public class UsageSubDTO : IBaseResponseDTO<Usage, UsageSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid CategoryId {get; set;}
        public Guid KindId {get; set;}

        public AnimalScale? ScaleSpecific {get; set;} = null;

        public int AverageDailyAmountGrams {get; set;}
        

        public static UsageSubDTO? FromEntity(Usage? usage)
        {
            if(usage==null){return null;}
            return new UsageSubDTO
            {
                Id=usage.Id,
                CurrentVersion=usage.CurrentVersion,
                CategoryId=usage.CategoryId,
                KindId=usage.KindId,
                ScaleSpecific=usage.ScaleSpecific,
                AverageDailyAmountGrams=usage.AverageDailyAmountGrams
            };

        }


    }
    public class CategoryDTO : ISerializableRequestDTO<Category>, IBaseResponseDTO<Category,CategoryDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;

        public bool Consumable { get; set; } = false;

        public List<UsageSubDTO?>? UsageSpecifics {get; set;} = null;

        public static CategoryDTO? FromEntity(Category? entity)
        {
            if(entity==null){return null;}
            return new CategoryDTO
            {
                Id = entity.Id,
                CurrentVersion= entity.CurrentVersion,
                Title = entity.Title,
                Consumable = entity.Consumable,
                UsageSpecifics = entity.UsageSpecifics.Select(u=>UsageSubDTO.FromEntity(u)).ToList()
            };
        }

        public Category? ToEntity()
        {
            Category category = new();
            category.CurrentVersion=CurrentVersion;
            category.Title=Title;
            category.Consumable=Consumable;
            return category;
        }
        
        
        public bool Validate()
        {
            return !string.IsNullOrWhiteSpace(Title);
        }



    }
}
