using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;


namespace PetCenterModels.DataTransferObjects
{

    public class AnnouncementSubDTO : IBaseResponseDTO<Announcement, AnnouncementSubDTO>
    {
        public Guid? Id {get; set;}
        public List<NoteSubDTO>? Notes {get; set;} = null;    

        public string Body {get; set;} = string.Empty;

        public static AnnouncementSubDTO? FromEntity(Announcement? announcement)
        {
            if(announcement==null){return null;}
            return new AnnouncementSubDTO
            {
                Id=announcement.Id,
                Body=announcement.Body
            };
        }
    }

    public class NotificationSubDTO : IBaseResponseDTO<Notification, NotificationSubDTO>
    {
        public Guid? Id {get; set;}
        public List<NoteSubDTO>? Notes {get; set;} = null;
        public Guid? ListingId {get; set;} = null;
        public string Title {get; set;} = string.Empty;

        public string Body {get; set;} = string.Empty;

        public static NotificationSubDTO? FromEntity(Notification? notification)
        {
            if(notification==null){return null;}
            return new NotificationSubDTO
            {
                Id=notification.Id,
                Title = notification.Title,
                Body=notification.Body,
                ListingId=notification.ListingId
            };
        }
    }

    public class SuppliesSubDTO : IBaseResponseDTO<Supplies,SuppliesSubDTO>
    {
        public Guid? Id {get; set;}

        public Guid KindId {get; set;}

        public Guid ConsumableId {get; set;}

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static SuppliesSubDTO? FromEntity(Supplies? supplies)
        {
            if(supplies==null || supplies.KindDetails==null || supplies.ConsumableCategory==null){return null;}
            SuppliesSubDTO output = new();

            output.Id=supplies.Id;
            output.KindId=supplies.KindId;
            output.ConsumableId=supplies.CategoryId;

            output.Notes=new();
            
            NoteSubDTO note = new();
            note.Title = $"{supplies.KindDetails.Title} - {supplies.ConsumableCategory.Title}";
            note.Body = $"Approximately {supplies.MassGrams}g left.";
            output.Notes.Add(note);

            return output;
        }
    }
    public class UserResponseDTO : IBaseResponseDTO<User,UserResponseDTO>
    {        
        public Guid? Id {get; set;}
        public string? UserName {get; set;}
        public List<NoteSubDTO>? Notes {get; set;}

        public List<AnnouncementSubDTO>? Announcements {get; set;} = null;

        public List<NotificationSubDTO>? Notifications {get; set;} = null;

        public List<ReportResponseSubDTO>? Reports {get; set;} = null;

        public static UserResponseDTO? FromEntity(User? usr)
        {
            if (usr==null){return null;}

            return new UserResponseDTO
            {
                Id=usr.Id,
                UserName=usr.UserName,
               
            };
        }
    }
}
