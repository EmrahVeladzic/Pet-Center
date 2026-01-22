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
    [Table("FormTemplate", Schema = "Business")]
    public class FormTemplate : BaseTableEntity
    {
        [Column("FormDescription")]
        public string? Description {get; set;}

        [NotMapped]
        public List<FormTemplateField>? Entries {get; set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Forms.Where(f=>f.FormTemplateId==Id).ToListAsync() is List<Form> f){foreach(Form frm in f){await frm.StageDeletion<Form>(ctx,ctx.Forms);}}
            if(await ctx.FormTemplateFields.Where(t=>t.FormTemplateId==Id).ToArrayAsync() is FormTemplateField[] t){ctx.FormTemplateFields.RemoveRange(t);}
            await base.StageDeletion(ctx, set);
        }
        
    }
}
