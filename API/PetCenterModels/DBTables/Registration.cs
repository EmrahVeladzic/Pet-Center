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
    [Table("Registration", Schema = "Pending")]
    public class Registration : ExpirableTableEntity
    {       
        [Column("AccountID")]
        public Guid AccountId { get; set; }

        [JsonIgnore]
        [ForeignKey(nameof(AccountId))]
        public Account? RelevantAccount { get; set; }

        [Column("Code")]
        public int Code { get; set; }


        [Column("NextAttempt")]
        public DateTime NextAttempt { get; set; }

        override public async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Accounts.FirstOrDefaultAsync(a => a.Id == AccountId) is Account a) { await a.StageDeletion<Account>(ctx, ctx.Accounts);}
            await base.StageDeletion<T>(ctx,set);
        }


    }
}
