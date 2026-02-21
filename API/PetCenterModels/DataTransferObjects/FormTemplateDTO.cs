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
    public class FormTemplateFieldDTO : ISerializableRequestDTO<FormTemplateField>, IBaseResponseDTO<FormTemplateField,FormTemplateFieldDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public Guid FormTemplateId {get; set;} = Guid.Empty;

        public string Description {get; set;} = string.Empty;

        public bool Optional { get; set; } = false;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static FormTemplateFieldDTO? FromEntity(FormTemplateField? entity)
        {
            if(entity==null){return null;}
            return new FormTemplateFieldDTO
            {
                Id = entity.Id,
                FormTemplateId = entity.FormTemplateId,
                Description = entity.Description,
                Optional = entity.Optional
            };
        }

        public FormTemplateField? ToEntity()
        {
            FormTemplateField formTemplateField = new();
           
            formTemplateField.FormTemplateId = FormTemplateId;
            formTemplateField.Description = Description;
            formTemplateField.Optional = Optional;
            return formTemplateField;
        }

        public bool Validate()
        {
            return FormTemplateId != Guid.Empty && !string.IsNullOrWhiteSpace(Description);
        }

    }

    public class FormTemplateDTO : ISerializableRequestDTO<FormTemplate>, IBaseResponseDTO<FormTemplate,FormTemplateDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Description {get; set;} = string.Empty;
        
        public List<FormTemplateFieldDTO> Fields {get; set;} = new();


        public static FormTemplateDTO? FromEntity(FormTemplate? entity)
        {
            if(entity==null){return null;}
            return new FormTemplateDTO
            {
                Id = entity.Id,
                Description = entity.Description,
                Fields = entity.Entries.Select(f=>FormTemplateFieldDTO.FromEntity(f)!).ToList()
            };
        }

        public FormTemplate? ToEntity()
        {
            FormTemplate formTemplate = new();
           
            formTemplate.Description = Description;

            return formTemplate;
        }
        
        
        public bool Validate()
        {
            return !string.IsNullOrWhiteSpace(Description);
        }



    }
}
