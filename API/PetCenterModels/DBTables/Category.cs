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
    [Table("Category",Schema ="Product")]
    public class Category : BaseTableEntity
    {
        [Column("Title")]
        public string Title { get; set; } = string.Empty;

        [Column("Consumable")]
        public bool Consumable { get; set; }

        [InverseProperty(nameof(Usage.ProductCategory))]
        public List<Usage> UsageSpecifics {get; set;} = new();

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Items.Where(i=>i.CategoryId==Id).ToListAsync() is List<Item> i){foreach(Item itm in i){await itm.StageDeletion<Item>(ctx,ctx.Items);}}
            if(await ctx.UsageEstimates.Where(u=>u.CategoryId==Id).ToArrayAsync() is Usage[] u){ctx.UsageEstimates.RemoveRange(u);}
            await base.StageDeletion(ctx, set);
        }
    }
}
