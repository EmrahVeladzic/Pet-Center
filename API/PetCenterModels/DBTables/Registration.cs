using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.ModelUtils;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    [Table("Registration", Schema = "Pending")]
    public class Registration : ExpirableTableEntity
    {      
       

     
        [ForeignKey(nameof(Id))]
        public Account RelevantAccount { get; set; } = null!;

        [Column("CodeSalt")]
        public string CodeSalt { get; set; } = string.Empty;

        [Column("CodeHash")]
        public string CodeHash { get; set; } = string.Empty;


        [Column("NextAttempt")]
        public DateTime NextAttempt { get; set; }

        override public async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set,CancellationToken cancel = default)
        {
            DBUtils.EnsureInTransaction(ctx);
            if(await ctx.Accounts.FindAsync(Id,cancel) is Account a) { await a.StageDeletion<Account>(ctx, ctx.Accounts,cancel);}
            await base.StageDeletion<T>(ctx,set,cancel);
        }


    }
}
