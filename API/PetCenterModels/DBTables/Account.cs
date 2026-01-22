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
    public enum Access : byte
    {
        Owner = 255,
        Admin = 254,
        BusinessManager = 2,
        BusinessEmployee = 1,
        User = 0
    }

    [Table("Account", Schema = "Person")]
    public class Account : BaseTableEntity
    {
        [Column("Contact")]
        [Required]
        public string? Contact {  get; set; }       

        [Column("PasswordHash")]
        [JsonIgnore]
        [Required]
        public string? PasswordHash { get; set; }

        [Column("PasswordSalt")]
        [JsonIgnore]
        public string? PasswordSalt { get; set; }

        [Column("AccessLevel")]
        [JsonIgnore]
        public Access AccessLevel { get; set; }

        [Column("Verified")]
        [JsonIgnore]
        public bool Verified { get; set; }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if (await ctx.Users.FirstOrDefaultAsync(u => u.AccountId == Id) is User u) {await u.StageDeletion<User>(ctx, ctx.Users);  ctx.Users.Remove(u);}
            if(await ctx.Albums.Where(a=>a.PosterID==Id).ToArrayAsync() is Album[]a){ctx.Albums.RemoveRange(a);}
            await base.StageDeletion<T>(ctx,set);
        }

    }
}
