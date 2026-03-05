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
        BusinessAccount = 1,
        User = 0
    }

    [Table("Account", Schema = "Person")]
    public class Account : BaseTableEntity
    {
        [Column("Contact")]
        [Required]
        public string Contact {  get; set; } = string.Empty;   

        [Column("PasswordHash")]
        [JsonIgnore]
        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Column("PasswordSalt")]
        [JsonIgnore]
        public string PasswordSalt { get; set; } = string.Empty;

        [Column("AccessLevel")]
        [JsonIgnore]
        public Access AccessLevel { get; set; }

        [Column("Verified")]
        [JsonIgnore]
        public bool Verified { get; set; }

        [InverseProperty(nameof(User.UserAccount))]
        public User AccountUser {get; set;} = null!;

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set, CancellationToken cancel = default)
        {
            if(await ctx.Users.FindAsync(Id,cancel) is User u) {await u.StageDeletion<User>(ctx, ctx.Users,cancel);  ctx.Users.Remove(u);}
            if(await ctx.Albums.Where(a=>a.PosterID==Id).ToArrayAsync(cancel) is Album[]a){ctx.Albums.RemoveRange(a);}
            await base.StageDeletion<T>(ctx,set,cancel);
        }

    }
}
