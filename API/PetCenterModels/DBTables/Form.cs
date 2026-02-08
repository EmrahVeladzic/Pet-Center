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
    [Table("Form", Schema = "Pending")]
    public class Form : AlbumIncludingTableEntity
    {
        [Column("FormTemplateID")]
        public Guid FormTemplateId { get; set; }

        [JsonIgnore]
        [Column("UserID")]
        public Guid UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public User RelevantUser {get; set;} = null!;
        
        [Column("FranchiseName")]
        public string FranchiseName { get; set; } = string.Empty;

        [Column("DefaultContact")]
        public string DefaultContact { get; set; } = string.Empty;

        [Column("Posted")]
        public DateTime Posted {get; set;}

        [InverseProperty(nameof(FormFieldEntry.RelevantForm))]
        public List<FormFieldEntry> Entries {get; set;} = new();

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.FormFieldEntries.Where(f=>f.FormId==Id).ToArrayAsync() is FormFieldEntry[] f){ctx.FormFieldEntries.RemoveRange(f);}
            await base.StageDeletion(ctx, set);
        }
    }
}
