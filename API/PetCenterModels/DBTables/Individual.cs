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
    public class Individual:BaseTableEntity
    {
        [Column("BreedID")]
        public Guid BreedId {get; set;}

        [Column("AnimalName")]
        public string? Name {get; set;}

        [Column("BirthDate")]
        public DateTime BirthDate {get; set;}

        [Column("AlbumID")]
        public Guid AlbumId {get; set;}

        [Column("Sex")]
        public bool Sex {get; set;}

        [ForeignKey(nameof(AlbumId))]
        public Album? Album {get; set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.AnimalPosessionRecords.Where(p=>p.Id==Id).FirstOrDefaultAsync() is Posession p){ctx.AnimalPosessionRecords.Remove(p);}
            if(await ctx.MedicalRecordEntries.Where(m=>m.AnimalId==Id).ToArrayAsync() is MedicalRecordEntry[] m){ctx.MedicalRecordEntries.RemoveRange(m);}
            await base.StageDeletion(ctx, set);
        }

    }
}
