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
    [Table("MedicalListing", Schema ="Offer")]
    public class MedicalListing : BaseTableEntity
    {

        [Column("ProcedureID")]
        public Guid ProcedureId {get; set;}

        [ForeignKey(nameof(ProcedureId))]
        public Procedure Procedure { get; set; } = null!;


        [ForeignKey(nameof(Id))]
        public Listing Base {get; set;} = null!;

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set,CancellationToken cancel = default)
        {
            if(await ctx.Listings.FirstOrDefaultAsync(l=>l.Id==Id,cancel) is Listing l){await l.StageDeletion(ctx, ctx.Listings,cancel);}
            await base.StageDeletion(ctx, set,cancel);
        }

    }
}
