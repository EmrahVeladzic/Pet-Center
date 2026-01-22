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
    [Table("AnimalListing", Schema ="Offer")]
    public class AnimalListing : BaseTableEntity
    {

        [Column("AnimalID")]
        public Guid AnimalId {get; set;}

        [ForeignKey(nameof(AnimalId))]
        public Individual? Animal { get; set; }


        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Listings.FirstOrDefaultAsync(l=>l.Id==Id) is Listing l){await l.StageDeletion(ctx, ctx.Listings);}
            await base.StageDeletion(ctx, set);
        }

    }
}
