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
    public class CategoryDTO : ISerializableRequestDTO<Category>, IBaseResponseDTO<Category,CategoryDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;

        public bool Consumable { get; set; } = false;


        public static CategoryDTO? FromEntity(Category? entity)
        {
            if(entity==null){return null;}
            return new CategoryDTO
            {
                Id = entity.Id,
                Title = entity.Title,
                Consumable = entity.Consumable
            };
        }

        public Category? ToEntity()
        {
            Category category = new();
           
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
