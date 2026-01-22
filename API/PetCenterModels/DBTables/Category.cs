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
        public string? Title { get; set; }

        [Column("Consumable")]
        public bool Consumable { get; set; }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Items.Where(i=>i.CategoryId==Id).ToListAsync() is List<Item> i){foreach(Item itm in i){await itm.StageDeletion<Item>(ctx,ctx.Items);}}
            await base.StageDeletion(ctx, set);
        }
    }
}
