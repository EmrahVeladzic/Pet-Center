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
        public Item? Product { get; set; }


        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Listings.FirstOrDefaultAsync(l=>l.Id==Id) is Listing l){await l.StageDeletion(ctx, ctx.Listings);}
            await base.StageDeletion(ctx, set);
        }

    }
}
