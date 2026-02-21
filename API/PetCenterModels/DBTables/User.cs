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
    [Table("User", Schema = "Person")]
    public class User : BaseTableEntity
    {

        [ForeignKey(nameof(Id))]
        public Account UserAccount { get; set; } = null!;

        [Column("UserName")]
        public string UserName { get; set; } = string.Empty;

        [InverseProperty(nameof(Individual.Owner))]
        public List<Individual> OwnedAnimals {get; set;} = new();

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Franchises.Where(f=>f.OwnerId==Id).ToListAsync() is List<Franchise> fr){foreach(Franchise fran in fr){await fran.StageDeletion<Franchise>(ctx,ctx.Franchises);}}
            if(await ctx.IndividualAnimals.Where(a=>a.OwnerId==Id && a.Owned==true).ToListAsync() is List<Individual> a){foreach(Individual ind in a){await ind.StageDeletion<Individual>(ctx,ctx.IndividualAnimals);}}
            if(await ctx.Forms.Where(f=>f.UserId==Id).ToListAsync() is List<Form>f){foreach(Form frm in f){await frm.StageDeletion<Form>(ctx,ctx.Forms);}}
            if(await ctx.Comments.Where(c=>c.PosterId==Id).ToListAsync() is List<Comment> c){foreach(Comment com in c){await com.StageDeletion<Comment>(ctx,ctx.Comments);}}
            if(await ctx.EmployeeRecords.Where(e=>e.UserId==Id).ToArrayAsync() is EmployeeRecord []e){ctx.EmployeeRecords.RemoveRange(e);}
            if(await ctx.Reports.Where(r=>r.ReporterId==Id).ToArrayAsync() is Report[] r){ctx.Reports.RemoveRange(r);}
        }
    }
}
