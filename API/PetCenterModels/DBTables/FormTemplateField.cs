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
  
    [Table("FormTemplateField", Schema = "Business")]
    public class FormTemplateField : BaseTableEntity
    {
        [Column("FormTemplateID")]
        public Guid FormTemplateId { get; set; }

        [Column("FormFieldDescription")]
        public string Description {get; set;} = string.Empty;

        [ForeignKey(nameof(FormTemplateId))]
        public FormTemplate Template {get; set;} = null!;


        [Column("Optional")]
        public bool Optional {get; set;}

        

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set,CancellationToken cancel = default)
        {
            if(await ctx.FormFieldEntries.Where(f=>f.FormTemplateFieldId==Id).ToArrayAsync(cancel) is FormFieldEntry[] f){ctx.FormFieldEntries.RemoveRange(f);}
            await base.StageDeletion(ctx, set,cancel);
        }
        
    }
}
