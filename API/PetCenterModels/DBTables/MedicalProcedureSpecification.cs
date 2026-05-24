using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.ModelUtils;
using PetCenterServices;


namespace PetCenterModels.DBTables
{
    [Table("MedicalProcedureSpecification",Schema ="Service")]
    public class MedicalProcedureSpecification:BaseTableEntity
    {

        [Column("ProcedureID")]
        public Guid ProcedureId {get; set;}

        [ForeignKey(nameof(ProcedureId))]
        public Procedure MedicalProcedure {get; set;} = null!;

        [Column("KindID")]
        public Guid KindId {get; set;}

        [Column("BreedID")]
        public Guid? BreedId {get; set;}

        [Column("ApproximateAgeDays")]
        public int? ApproximateAge {get; set;}

        
        [Column("SexSpecific")]
        public bool? SexSpecific {get; set;}


        [NotMapped]
        public string SexSpecifier => SexSpecific switch{
            true=> "Male",
            false=> "Female",
            null => "Both"
        };        

        [Column("Optional")]
        public bool Optional {get; set;}

        [Column("IntervalDays")]
        public short? IntervalDays {get; set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set, CancellationToken cancel = default)
        {
            DBUtils.EnsureInTransaction(ctx);
            if (BreedId == null)
            {
                if(await ctx.MedicalProcedureSpecifications.Where(s=>s.KindId==KindId&&s.BreedId!=null&&s.ProcedureId==ProcedureId&&s.ApproximateAge==null).ToArrayAsync() is MedicalProcedureSpecification[] s){ctx.MedicalProcedureSpecifications.RemoveRange(s);}
            }
            await base.StageDeletion(ctx, set, cancel);
        }

    }
}
