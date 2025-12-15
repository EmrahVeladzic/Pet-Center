using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    [Table( "Comment",Schema ="Communication")]
    public class Comment : BaseTableEntity
    {
        [Column("PosterID")]
        public Guid? PosterId { get; set; }

        [JsonIgnore]
        [ForeignKey(nameof(PosterId))]
        public User? Poster {  get; set; }

        [NotMapped]
        public string PosterName => Poster?.UserName ?? "Null";

        [Column("Contents")]
        public string? Message { get; set; }
        [Column("Creation")]
        public DateTime PostDate { get; set; }
        [Column("Edited")]
        public bool Edited { get; set; }
        [Column("ParentCommentID")]
        public Guid? ReplyingTo { get; set; }
        [Column("ThreadID")]
        public Guid ThreadId { get; set; }

    }
}
