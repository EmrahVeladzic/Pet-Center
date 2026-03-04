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
        Generic = 0,
        Product = 1,
        Pet = 2,
        Medical = 3
    }

    [Table("Listing", Schema = "Offer")]
    public class Listing : AlbumIncludingTableEntity
    {
        [Column("ListingName")]
        public string ListingName { get; set; } = string.Empty;
        [Column("ListingDescription")]
        public string ListingDescription { get; set; } = string.Empty;

        [Column("ListingType")]
        public ListingType Type { get; set; } = ListingType.Generic;
        
        [Column("PriceMinor")]
        public long PriceMinor {get; set;} = 0;


        [Column("FranchiseID")]
        public Guid FranchiseId { get; set; }

        [Column("Visible")]
        public bool Visible { get; set; } = false;

        [Column("Approved")]
        public bool Approved { get; set; } = false;

        [Column("Posted")]
        public DateTime Posted {get; set;} = DateTime.UtcNow;

        [Column("Updated")]
        public bool Updated {get; set;} = true;

        [JsonIgnore]
        [ForeignKey(nameof(FranchiseId))]
        public Franchise Business {  get; set; } = null!;

        [InverseProperty(nameof(Discount.RelevantListing))]
        public Discount? ListingDiscount {get; set;} = null;

        [InverseProperty(nameof(Comment.RelevantListing))]
        public List<Comment> Comments { get; set; } = new();

        [InverseProperty(nameof(Available.RelevantListing))]
        public List<Available> AvailabilityRecords {get; set;} = new();

        [InverseProperty(nameof(AnimalListing.Base))]
        public AnimalListing? AnimalExtension {get; set;} = null;

        [InverseProperty(nameof(ProductListing.Base))]
        public ProductListing? ProductExtension {get; set;} = null;

        [InverseProperty(nameof(MedicalListing.Base))]
        public MedicalListing? MedicalExtension {get; set;} = null;

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.AnimalListings.FirstOrDefaultAsync(a=>a.Id == Id) is AnimalListing al){ctx.AnimalListings.Remove(al);}
            if(await ctx.ProductListings.FirstOrDefaultAsync(p=>p.Id == Id) is ProductListing pl){ctx.ProductListings.Remove(pl);}
            if(await ctx.MedicalListings.FirstOrDefaultAsync(m=>m.Id == Id) is MedicalListing ml){ctx.MedicalListings.Remove(ml);}
            if(await ctx.ListingAvailable.Where(a=>a.ListingId == Id).ToArrayAsync() is Available[] a){ctx.ListingAvailable.RemoveRange(a);}
            if(await ctx.Comments.Where(c=>c.ListingId==Id).ToListAsync() is List<Comment> c){foreach(Comment comm in c){await comm.StageDeletion(ctx, ctx.Comments);}}
            if(await ctx.Notifications.Where(n=>n.ListingId==Id).ToArrayAsync() is Notification[] n){ctx.Notifications.RemoveRange(n);}
            if(await ctx.Reports.Where(r=>r.ListingId==Id).ToArrayAsync() is Report[] r){ctx.Reports.RemoveRange(r);}
            await base.StageDeletion(ctx, set);
        }

    }
}
