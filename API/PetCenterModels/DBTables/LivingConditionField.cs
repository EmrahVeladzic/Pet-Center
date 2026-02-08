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
    [Table("LivingConditionField", Schema = "Person")]
    public class LivingConditionField : BaseTableEntity
    {
        [Column("Title")]
        public string Title { get; set; } = string.Empty;

        [Column("InvestmentEffect")]
        public float InvestmentEffect { get; set; }

        [Column("TerritoryEffect")]
        public float TerritoryEffect { get; set; }

        [Column("PricingEffect")]
        public float PricingEffect { get; set; }

        [Column("LongevityEffect")]
        public float LongevityEffect { get; set; }

        [Column("CohabitationEffect")]
        public float CohabitationEffect { get; set; }

        
    }
}
