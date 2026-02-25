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
    [Table("Usage", Schema = "Animal")]
    public class Usage : BaseTableEntity
    {
        [Column("KindID")]
        public Guid KindId {get;set;}

        [Column("ScaleSpecific")]
        public AnimalScale? ScaleSpecific {get;set;}

        [Column("CategoryID")]
        public Guid CategoryId {get;set;}

        [Column("AverageDailyAmountGrams")]
        public int AverageDailyAmountGrams {get;set;}

        [ForeignKey(nameof(CategoryId))]
        public Category ProductCategory {get; set;} = null!;

        [ForeignKey(nameof(KindId))]
        public Kind AnimalKind {get; set;} = null!;

        
    }
}
