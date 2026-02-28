using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    [Table( "Comment",Schema ="Communication")]
    public class Comment : BaseTableEntity
    {
        [Column("PosterID")]
        public Guid PosterId { get; set; }

        [JsonIgnore]
        [ForeignKey(nameof(PosterId))]
        public User Poster {  get; set; } = null!;

        [Column("Contents")]
        public string Message { get; set; } = string.Empty;
        [Column("LastEdited")]
        public DateTime LastEditDate { get; set; }
       
        [Column("ListingID")]
        public Guid ListingId { get; set; }

        [ForeignKey(nameof(ListingId))]
        public Listing RelevantListing {get; set;} = null!;

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Reports.Where(r=>r.CommentId==Id).ToArrayAsync() is Report[] r){ctx.Reports.RemoveRange(r);}
            await base.StageDeletion(ctx, set);
        }

    }
}
