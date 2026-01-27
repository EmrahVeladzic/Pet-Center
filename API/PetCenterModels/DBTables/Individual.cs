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

    [Table("Individual",Schema ="Animal")]
    public class Individual:AlbumIncludingTableEntity
    {
        [Column("BreedID")]
        public Guid BreedId {get; set;}

        [Column("AnimalName")]
        public string? Name {get; set;}

        [Column("BirthDate")]
        public DateTime BirthDate {get; set;}

        [Column("Sex")]
        public bool Sex {get; set;}       

        [Column("OwnerID")]
        public Guid? OwnerId {get;set;}

        [Column("ShelterID")]
        public Guid? ShelterId {get;set;}

        public bool Owned {get;set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.MedicalRecordEntries.Where(m=>m.AnimalId==Id).ToArrayAsync() is MedicalRecordEntry[] m){ctx.MedicalRecordEntries.RemoveRange(m);}
            if(await ctx.AnimalListings.FirstOrDefaultAsync(a=>a.AnimalId==Id) is AnimalListing a){await a.StageDeletion<AnimalListing>(ctx,ctx.AnimalListings);}
            await base.StageDeletion(ctx, set);
        }

    }
}
