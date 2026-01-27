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

    public enum AnimalScale : byte
    {
        Small = 0,
        Medium = 1,
        Large = 2
    }

    [Table("Breed",Schema ="Animal")]
    public class Breed:AlbumIncludingTableEntity
    {
        [Column("Title")]
        public string? Title {get; set;}

        [Column("KindID")]
        public Guid KindId {get; set;}

        [Column("Scale")]
        public AnimalScale Scale {get; set;}

        [Column("Investment")]
        public float Investment {get; set;}

        [Column("Territory")]
        public float Territory {get; set;}

        [Column("Pricing")]
        public float Pricing {get; set;}

        [Column("Longevity")]
        public float Longevity {get; set;}
        
        [Column("Cohabitation")]
        public float Cohabitation {get; set;}


        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.IndividualAnimals.Where(i=>i.BreedId==Id).ToListAsync() is List<Individual> i){foreach (Individual ind in i){await ind.StageDeletion<Individual>(ctx,ctx.IndividualAnimals);}}
            if(await ctx.MedicalProcedureSpecifications.Where(m=>m.BreedId==Id).ToListAsync() is List<MedicalProcedureSpecification> m){foreach (MedicalProcedureSpecification med in m){await med.StageDeletion<MedicalProcedureSpecification>(ctx,ctx.MedicalProcedureSpecifications);}}
            await base.StageDeletion(ctx, set);
        }

    }
}
