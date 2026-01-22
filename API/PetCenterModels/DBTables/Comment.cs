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

        [Column("Contents")]
        public string? Message { get; set; }
        [Column("Creation")]
        public DateTime PostDate { get; set; }
       
        [Column("ListingID")]
        public Guid ListingId { get; set; }

    }
}
