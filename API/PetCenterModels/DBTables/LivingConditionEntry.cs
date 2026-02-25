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
    [Table("LivingConditionEntry", Schema = "Person")]
    public class LivingConditionEntry : BaseTableEntity
    {
        [Column("UserID")]
        public Guid UserId { get; set; }

        [Column("LivingConditionFieldID")]
        public Guid LivingConditionFieldID { get; set; }

        [ForeignKey(nameof(LivingConditionFieldID))]
        public LivingConditionField Field {get; set;} = null!;

        [Column("Answer")]
        public bool Answer { get; set; }
    }
}
