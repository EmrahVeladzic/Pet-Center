using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    [Table("Form", Schema = "Pending")]
    public class Form : BaseTableEntity
    {
        [Column("FormTemplateID")]
        public Guid FormTemplateId { get; set; }

        [JsonIgnore]
        [Column("UserID")]
        public Guid UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public User? RelevantUser {get; set;}

        [JsonIgnore]
        [Column("AlbumID")]
        public Guid AlbumId {get; set;}

        [ForeignKey(nameof(AlbumId))]
        public Album? Attachment {get; set;}

        [NotMapped]
        public List<FormFieldEntry>? Entries {get; set;}
    }
}
