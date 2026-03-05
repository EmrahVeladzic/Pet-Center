using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    public class BaseTableEntity
    {
        [Key]
        [Column("ID")]
        public Guid Id { get; set; }

        [Column("CurrentVersion")]
        [Timestamp]
        public byte[] CurrentVersion { get; set; } = null!;


        public BaseTableEntity()
        {
            
        }

        public virtual Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set, CancellationToken cancel = default) where T: BaseTableEntity
        {
            set.Remove((T)this);
            return Task.CompletedTask;
        }

    }
}
