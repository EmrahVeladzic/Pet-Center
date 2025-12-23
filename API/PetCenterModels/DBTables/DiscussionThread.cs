using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    [Table("Thread", Schema = "Communication")]
    public class DiscussionThread : BaseTableEntity
    {
        [Column("Title")]
        public string? Title { get; set; }
        [Column("Contents")]
        public string? Description { get; set; }
        [Column("PosterID")]
        public Guid OriginalPosterId {  get; set; }

        [JsonIgnore]
        [ForeignKey(nameof(OriginalPosterId))]
        public User? OriginalPoster { get; set; }

        [NotMapped]
        public string OriginalPosterName => OriginalPoster?.UserName ?? "Null";

        [Column("Creation")]
        public DateTime CreationTime { get; set; }

        [Column("Edited")]
        public bool Edited { get; set; }

        [Column("ListingID")]
        public Guid ListingId { get; set; }

        [NotMapped]
        public List<Comment>? Comments { get; set; }
    }
}
