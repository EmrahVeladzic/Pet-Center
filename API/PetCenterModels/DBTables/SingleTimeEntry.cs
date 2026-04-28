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
    [Table("SingleTimeEntry", Schema = "Pending")]
    public class SingleTimeEntry : ExpirableTableEntity
    {             

        [JsonIgnore]
        [ForeignKey(nameof(Id))]
        public Account RelevantAccount { get; set; } = null!;

        [Column("CodeSalt")]
        public string CodeSalt { get; set; } = string.Empty;

        [Column("CodeHash")]
        public string CodeHash { get; set; } = string.Empty;
       

    }
}
