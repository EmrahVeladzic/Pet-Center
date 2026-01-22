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
        [Column("AccountID")]
        [JsonIgnore]
        public Guid AccountId { get; set; }

        [ForeignKey(nameof(AccountId))]
        [JsonIgnore]
        public Account? UserAccount { get; set; }

        [Column("UserName")]
        public string? UserName { get; set; }

        [Column("ProfilePictureID")]
        [JsonIgnore]
        public Guid PictureId { get; set; }

        [ForeignKey(nameof(PictureId))]
        public Album? Picture { get; set; }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.AnimalPosessionRecords.Where(p=>p.OwnerId==Id && p.Owned==true).ToListAsync() is List<Posession> p){foreach(Posession pos in p){Individual? ind = await ctx.IndividualAnimals.FindAsync(pos.Id); if(ind!=null){await ind.StageDeletion<Individual>(ctx,ctx.IndividualAnimals);}}}
            if(await ctx.Forms.Where(f=>f.UserId==Id).ToListAsync() is List<Form>f){foreach(Form frm in f){await frm.StageDeletion<Form>(ctx,ctx.Forms);}}
            if(await ctx.Comments.Where(c=>c.PosterId==Id).ToArrayAsync() is Comment[] c){ctx.Comments.RemoveRange(c);}
            if(await ctx.Wishlists.Where(w=>w.UserId==Id).ToArrayAsync() is Wishlist[] w){ctx.Wishlists.RemoveRange(w);}
            if(await ctx.EmployeeRecords.Where(e=>e.UserId==Id).ToArrayAsync() is EmployeeRecord []e){ctx.EmployeeRecords.RemoveRange(e);}
        }
    }
}
