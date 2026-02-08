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
    [Table("Facility", Schema = "Business")]
    public class Facility : BaseTableEntity
    {

        [Column("FranchiseID")]
        [JsonIgnore]
        public Guid FranchiseId { get; set; }

        [ForeignKey(nameof(FranchiseId))]
        public Franchise OwningFranchise {get; set;} = null!;

        [Column("Street")]
        public string Street { get; set; } = string.Empty;

        [Column("City")]
        public string City { get; set; } = string.Empty;

        [Column("Contact")]        
        public string Contact {  get; set; } = string.Empty;

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.ListingAvailable.Where(a=>a.FacilityId == Id).ToArrayAsync() is Available[] a){ctx.ListingAvailable.RemoveRange(a);}
            await base.StageDeletion(ctx, set);
        }
    }
}
