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
    [Table("Item",Schema ="Product")]
    public class Item : BaseTableEntity
    {
        [Column("CategoryID")]
        public Guid CategoryId { get; set; }

        [Column("TargetKind")]
        public Guid? TargetKind { get; set; }

        [Column("TargetScale")]
        public byte? TargetScale { get; set; }

        [Column("MassGrams")]
        public int MassGrams { get; set; }

    }
}
