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
    public class Form : BaseTableEntity
    {
        [Column("FormTemplateID")]
        public Guid FormTemplateId { get; set; }

        [Column("Expiry")]
        public DateTime Expiry {  get; set; }

        [JsonIgnore]
        [Column("UserID")]
        public Guid UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public User? RelevantUser {get; set;}

        [JsonIgnore]
        [Column("AlbumID")]
        public Guid AlbumId {get; set;}

        [ForeignKey(nameof(AlbumId))]
        public Album? Attachment {get; set;}

        [NotMapped]
        public List<FormFieldEntry>? Entries {get; set;}

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.FormFieldEntries.Where(f=>f.FormId==Id).ToListAsync() is List<FormFieldEntry> f){foreach(FormFieldEntry ffe in f){await ffe.StageDeletion<FormFieldEntry>(ctx,ctx.FormFieldEntries);}}
            await base.StageDeletion(ctx, set);
        }
    }
}
