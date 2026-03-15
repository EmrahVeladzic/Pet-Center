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
    public class FormEntrySubDTO : ISerializableRequestDTO<FormFieldEntry>, IBaseResponseDTO<FormFieldEntry,FormEntrySubDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public Guid FormId {get; set;} = Guid.Empty;

        public Guid FormTemplateFieldId {get; set;} = Guid.Empty;

        public string Serialized {get; set;} = string.Empty;
        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static FormEntrySubDTO? FromEntity(FormFieldEntry? entity)
        {
            if(entity==null){return null;}
            return new FormEntrySubDTO
            {
                Id = entity.Id,
                CurrentVersion=entity.CurrentVersion,
                FormTemplateFieldId=entity.FormTemplateFieldId,
                FormId = entity.FormId,
                Serialized=entity.Serialized
            };
        }

        public FormFieldEntry? ToEntity()
        {
            FormFieldEntry field = new();
            field.CurrentVersion=CurrentVersion;
            field.FormId=FormId;
            field.FormTemplateFieldId=FormTemplateFieldId;
            field.Serialized=Serialized;          
            
            return field;
        }

        public bool Validate()
        {
            return FormTemplateFieldId != Guid.Empty && !string.IsNullOrWhiteSpace(Serialized);
        }

    }

    public class FormDTO : ISerializableRequestDTO<Form>, IAlbumCarryingDTO<Form,FormDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string FranchiseName {get; set;} = string.Empty;

        public string DefaultContact {get; set;} = string.Empty;
        
        public List<FormEntrySubDTO> Entries {get; set;} = new();

        public Guid UserId {get; set;} = Guid.Empty;

        public Guid FormTemplateId {get; set;} = Guid.Empty;

        public Guid AlbumId {get; set;} = Guid.Empty;

        public List<ImageDTO> Images {get; set;} = new();


        public static FormDTO? FromEntity(Form? entity)
        {
            if(entity==null){return null;}
            return new FormDTO
            {
                Id = entity.Id,
                CurrentVersion = entity.CurrentVersion,
                DefaultContact = entity.DefaultContact,
                FranchiseName=entity.FranchiseName,
                UserId=entity.UserId,
                FormTemplateId=entity.FormTemplateId,
                AlbumId=entity.AlbumId,
                Images = entity.Album.Images.Select(i=>ImageDTO.FromEntity(i)!).ToList(),
                Entries = entity.Entries.Select(f=>FormEntrySubDTO.FromEntity(f)!).ToList()
            };
        }

        public Form? ToEntity()
        {
            Form form = new();
            form.CurrentVersion=CurrentVersion;
            form.UserId=UserId;
            form.AlbumId=AlbumId;
            form.DefaultContact=DefaultContact;
            form.FranchiseName=FranchiseName;
            form.FormTemplateId=FormTemplateId;          
           
            return form;
        }
        
        
        public bool Validate()
        {
            DefaultContact=DefaultContact.ToLowerInvariant();
            if(string.IsNullOrWhiteSpace(FranchiseName)){return false;}
            EmailAddressAttribute e = new();
            if(!e.IsValid(DefaultContact)){return false;}
            if(UserId==Guid.Empty){return false;}
            if(FormTemplateId==Guid.Empty){return false;}

            if(Entries.Any(e=>!e.Validate())){return false;}

            return true;
        }



    }
}
