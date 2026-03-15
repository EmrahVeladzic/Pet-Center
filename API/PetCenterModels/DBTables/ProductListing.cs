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
    [Table("ProductListing", Schema ="Offer")]
    public class ProductListing : BaseTableEntity
    {

        [Column("ProductID")]
        public Guid ProductId {get; set;}

        [ForeignKey(nameof(ProductId))]
        public Item Product { get; set; } = null!;

        [Column("PerListing")]
        public byte PerListing {get; set;}

        [ForeignKey(nameof(Id))]
        public Listing Base {get; set;} = null!;


        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set,CancellationToken cancel = default)
        {
            if(await ctx.Listings.FirstOrDefaultAsync(l=>l.Id==Id,cancel) is Listing l){await l.StageDeletion(ctx, ctx.Listings,cancel);}
            await base.StageDeletion(ctx, set,cancel);
        }

    }
}
