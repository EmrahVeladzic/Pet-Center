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

    public enum ListingType : byte
    {
        Service = 0,
        Product = 1,
        Pet = 2,
        Medical = 3
    }

    [Table("Listing", Schema = "Offer")]
    public class Listing : BaseTableEntity
    {
        [Column("ListingName")]
        public string? ListingName { get; set; }
        [Column("ListingDescription")]
        public string? ListingDescription { get; set; }

        [Column("ListingType")]
        public ListingType Type { get; set; }
        
        [Column("PriceMinor")]
        public long PriceMinor {get; set;}

        [Column("AlbumID")]
        [JsonIgnore]
        public Guid AlbumId { get; set; }

        [Column("FranchiseID")]
        public Guid? FranchiseId { get; set; }

        [Column("Expiry")]
        public DateTime Expiry { get; set; }

        [JsonIgnore]
        [ForeignKey(nameof(FranchiseId))]
        public Franchise? Business {  get; set; }

       
        [ForeignKey(nameof(AlbumId))]
        public Album? Images { get; set; }

        [NotMapped]
        public List<Comment>? Comments { get; set; }


        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.ListingAvailable.Where(a=>a.ListingId == Id).ToArrayAsync() is Available[] a){ctx.ListingAvailable.RemoveRange(a);}
            if(await ctx.Comments.Where(c=>c.ListingId==Id).ToArrayAsync() is Comment[] c){ctx.Comments.RemoveRange(c);}
            await base.StageDeletion(ctx, set);
        }

    }
}
