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

        public BaseTableEntity()
        {
            
        }

        public virtual async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set) where T: BaseTableEntity
        {
            set.Remove((T)this);
            await Task.CompletedTask;
        }

    }
}
