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
    [Table("Supplies", Schema = "Person")]
    public class Supplies : BaseTableEntity
    {
       
        [Column("UserID")]
        public Guid UserId { get; set; }

        [Column("ConsumableID")]
        public Guid CategoryId {get; set;}

        [ForeignKey(nameof(CategoryId))]
        public Category ConsumableCategory {get; set;} = null!;

        [Column("KindID")]
        public Guid KindId {get; set;}

        [ForeignKey(nameof(KindId))]
        public Kind KindDetails {get; set;} = null!;

        [Column("MassGrams")]
        public int MassGrams {get; set;}

    }
}
