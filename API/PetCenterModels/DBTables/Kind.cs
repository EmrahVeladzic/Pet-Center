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
    [Table("Kind",Schema ="Animal")]
    public class Kind:BaseTableEntity
    {
        [Column("Title")]
        public string Title {get; set;} = string.Empty;

        [InverseProperty(nameof(Breed.AnimalKind))]
        public List<Breed> Breeds {get; set;} = new();

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.AnimalBreeds.Where(b=>b.KindId==Id).ToListAsync() is List<Breed> b){foreach(Breed br in b){await br.StageDeletion<Breed>(ctx,ctx.AnimalBreeds);}}
            if(await ctx.MedicalProcedureSpecifications.Where(m=>m.KindId==Id).ToListAsync() is List<MedicalProcedureSpecification> m){foreach (MedicalProcedureSpecification med in m){await med.StageDeletion<MedicalProcedureSpecification>(ctx,ctx.MedicalProcedureSpecifications);}}
            if(await ctx.Items.Where(i=>i.KindId==Id).ToListAsync() is List<Item> i){foreach(Item itm in i){await itm.StageDeletion<Item>(ctx,ctx.Items);}}
            if(await ctx.UsageEstimates.Where(u=>u.KindId==Id).ToArrayAsync() is Usage[] u){ctx.RemoveRange(u);}
            await base.StageDeletion(ctx, set);
        }
    }
}
