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
using PetCenterModels.ModelUtils;

namespace PetCenterModels.DataTransferObjects
{
    public class FormEntrySubDTO : ISerializableRequestDTO<FormFieldEntry>, IBaseResponseDTO<FormFieldEntry,FormEntrySubDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public Guid? FormId {get; set;} = null;

        public Guid FormTemplateFieldId {get; set;} = Guid.Empty;

        [MaxLength(255)]
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
            if(FormId!=null){
            field.FormId=FormId.Value;
            }
            field.FormTemplateFieldId=FormTemplateFieldId;
            field.Serialized=Serialized;          
            
            return field;
        }

        public bool Validate()
        {
            return FormTemplateFieldId != Guid.Empty && !string.IsNullOrWhiteSpace(Serialized);
        }

    }

    public class FormDTO : ISerializableRequestDTO<Form>, IAlbumCarryingDTO<Form,FormDTO,ImageDTO,Image,ImageMetadata>
    {
       
        public Guid? Id {get; set;} = null;

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        [MaxLength(75)]
        public string FranchiseName {get; set;} = string.Empty;

        [MaxLength(255)]
        public string DefaultContact {get; set;} = string.Empty;
        
        public List<FormEntrySubDTO> Entries {get; set;} = new();

        public Guid UserId {get; set;} = Guid.Empty;

        public Guid FormTemplateId {get; set;} = Guid.Empty;

        public Guid? AlbumId {get; set;} = null;
        public bool Locked {get; set;} = true;

        public List<ImageDTO> Media {get; set;} = new();

        public string? MediaCreationToken {get; set;} = string.Empty;

        public bool Full {get; set;} = true;


        public string? EvalContact {get; set;} = null;
        public DateTime? EvalDate {get; set;} = null;

        public string? EvalReason {get; set;} = null;

        public EvaluationStatus Status {get; set;} = EvaluationStatus.Pending;



        public static FormDTO? FromEntity(Form? entity)
        {
            if(entity==null){return null;}
            FormDTO output = new FormDTO
            {
                Id = entity.Id,
                CurrentVersion = entity.CurrentVersion,
                DefaultContact = entity.DefaultContact,
                FranchiseName=entity.FranchiseName,
                UserId=entity.UserId,
                FormTemplateId=entity.FormTemplateId,
                AlbumId=entity.AlbumId,                
                Entries = entity.Entries.Select(f=>FormEntrySubDTO.FromEntity(f)!).ToList(),
                EvalContact = entity.Evaluator?.Contact??entity.EvaluatorContact,
                EvalReason=entity.Reason,
                EvalDate=entity.EvaluationDate,
                Status=entity.Status
                
            };

            if (entity.Album != null)
            {
                output.Media = entity.Album.Images.Select(i=>ImageDTO.FromEntity(i)!).ToList();
                output.Locked=entity.Album.Locked;
                output.Full=entity.Album.Reserved>=entity.Album.Capacity;
            }

            return output;
        }

        public static FormDTO? FromEntity(Form? entity, string token)
        {
            FormDTO? output = FromEntity(entity);

            if (output != null)
            {
              
                output.MediaCreationToken=token;
            }


            return output;
        }


        public static FormDTO? FromEntity(Form? entity, bool wipeContact)
        {
            FormDTO? output = FromEntity(entity);

            if (output != null && wipeContact)
            {
              
                output.EvalContact=null;
            }


            return output;
        }

        public Form? ToEntity()
        {
            Form form = new();
            form.CurrentVersion=CurrentVersion;
            form.UserId=UserId;
            if(AlbumId!=null){
                form.AlbumId=AlbumId.Value;
            }
            form.DefaultContact=DefaultContact;
            form.FranchiseName=FranchiseName;
            form.FormTemplateId=FormTemplateId;          
           
            return form;
        }
        
        
        public bool Validate()
        {
            DefaultContact=DefaultContact.ToLowerInvariant();
            if(string.IsNullOrWhiteSpace(FranchiseName)){return false;}
            
            if(!ModelValidationUtils.ValidateContact(DefaultContact)){return false;}
            if(UserId==Guid.Empty){return false;}
            if(FormTemplateId==Guid.Empty){return false;}

            if(Entries.Any(e=>!e.Validate())){return false;}

            return true;
        }



    }
}
