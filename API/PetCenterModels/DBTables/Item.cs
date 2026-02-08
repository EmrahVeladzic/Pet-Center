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
    [Table("Item",Schema ="Product")]
    public class Item : BaseTableEntity
    {
        [Column("Title")]
        public string Title { get; set; } = string.Empty;

        [Column("CategoryID")]
        public Guid CategoryId { get; set; }

        [Column("TargetKind")]
        public Guid? TargetKind { get; set; }

        [Column("TargetScale")]
        public byte? TargetScale { get; set; }

        [Column("MassGrams")]
        public int MassGrams { get; set; }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.ProductListings.Where(p=>p.ProductId==Id).ToListAsync() is List<ProductListing> p){foreach(ProductListing pl in p){await pl.StageDeletion<ProductListing>(ctx,ctx.ProductListings);}}
            await base.StageDeletion(ctx, set);
        }

    }
}
