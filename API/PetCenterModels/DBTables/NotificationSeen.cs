using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    [Table("NotificationSeen", Schema = "Communication")]
    public class NotificationSeen : BaseTableEntity
    {
        [Column("UserID")]
        public Guid UserId { get; set; } = Guid.Empty;

        [ForeignKey(nameof(UserId))]
        public User RelevantUser {get; set;}= null!;

        [Column("NotificationID")]
        public Guid NotificationId {get; set;} = Guid.Empty;

        [ForeignKey(nameof(NotificationId))]
        public Notification RelevantNotification {get; set;} = null!;

    }
}
