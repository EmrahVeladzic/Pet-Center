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
    [Table("MedicalProcedure",Schema ="Service")]
    public class Procedure:BaseTableEntity
    {
        

        [Column("ProcedureDescription")]
        public string? Description {get; set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.MedicalProcedureSpecifications.Where(s=>s.ProcedureId == Id).ToArrayAsync() is MedicalProcedureSpecification[] s){ctx.MedicalProcedureSpecifications.RemoveRange(s);}
            if(await ctx.MedicalRecordEntries.Where(m=>m.ProcedureId==Id).ToArrayAsync() is MedicalRecordEntry[] m){ctx.MedicalRecordEntries.RemoveRange(m);}
            if(await ctx.MedicalListings.Where(l=>l.ProcedureId==Id).ToListAsync() is List<MedicalListing> l){foreach(MedicalListing ml in l){await ml.StageDeletion<MedicalListing>(ctx,ctx.MedicalListings);}}
            await base.StageDeletion(ctx, set);
        }

    }
}
