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
    [Table("Franchise", Schema = "Business")]
    public class Franchise : AlbumIncludingTableEntity
    {
        [Column("OwnerID")]
        [JsonIgnore]
        public Guid OwnerId { get; set; }

        
        [ForeignKey(nameof(OwnerId))]
        [JsonIgnore]
        public User? Owner { get; set; }

        [Column("FranchiseName")]
        public string? FranchiseName { get; set; }

        [Column("DefaultContact")]        
        public string? Contact {  get; set; }

        [NotMapped]
        public List<Facility>? Facilities { get; set; }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.IndividualAnimals.Where(a=>a.ShelterId==Id && a.Owned==false).ToListAsync() is List<Individual> a){foreach(Individual ind in a){await ind.StageDeletion<Individual>(ctx,ctx.IndividualAnimals);}}
            if(await ctx.Listings.Where(l=>l.FranchiseId==Id).ToListAsync() is List<Listing> l){foreach(Listing lst in l){await lst.StageDeletion<Listing>(ctx,ctx.Listings);}}
            if(await ctx.EmployeeRecords.Where(e=>e.FranchiseId==Id).ToArrayAsync() is EmployeeRecord []e){ctx.EmployeeRecords.RemoveRange(e);}
            if(await ctx.Facilities.Where(f=>f.FranchiseId==Id).ToListAsync() is List<Facility> f){foreach(Facility fac in f){await fac.StageDeletion<Facility>(ctx,ctx.Facilities);}}
            if(await ctx.Notifications.Where(n=>n.FranchiseId==Id).ToArrayAsync() is Notification[] n){ctx.Notifications.RemoveRange(n);}
            await base.StageDeletion(ctx, set);
        }

    }
}
