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
        Consumable = 2,
        Pet = 3,
        Medical = 4
    }

    [Table("Listing", Schema = "Offer")]
    public class Listing : AlbumIncludingTableEntity
    {
        [Column("ListingName")]
        public string? ListingName { get; set; }
        [Column("ListingDescription")]
        public string? ListingDescription { get; set; }

        [Column("ListingType")]
        public ListingType Type { get; set; }
        
        [Column("PriceMinor")]
        public long PriceMinor {get; set;}


        [Column("FranchiseID")]
        public Guid? FranchiseId { get; set; }

        [Column("Visible")]
        public bool Visible { get; set; }

        [Column("Approved")]
        public bool Approved { get; set; }

        [Column("Posted")]
        public DateTime Posted {get; set;}

        [Column("Updated")]
        public bool Updated {get; set;}

        [JsonIgnore]
        [ForeignKey(nameof(FranchiseId))]
        public Franchise? Business {  get; set; }


        [NotMapped]
        public List<Comment>? Comments { get; set; }


        public override byte AlbumCapacity =>5;


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
