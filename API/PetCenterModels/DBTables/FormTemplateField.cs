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
    public enum DataType : byte
    {
        String = 0,
        Integer = 1,       
        Double = 2,
        Boolean = 3,
        DateTime = 4
    }

    [Table("FormTemplateField", Schema = "Business")]
    public class FormTemplateField : BaseTableEntity
    {
        [Column("FormTemplateID")]
        public Guid FormTemplateId { get; set; }

        [Column("FormFieldDescription")]
        public string? Description {get; set;}

        [Column("DataType")]
        public DataType DataType {get; set;}
       
        [Column("Optional")]
        public bool Optional {get; set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.FormFieldEntries.Where(f=>f.FormTemplateFieldId==Id).ToListAsync() is List<FormFieldEntry> f){foreach(FormFieldEntry ffe in f){await ffe.StageDeletion<FormFieldEntry>(ctx,ctx.FormFieldEntries);}}
            await base.StageDeletion(ctx, set);
        }
        
    }
}
