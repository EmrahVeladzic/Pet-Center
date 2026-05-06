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
    [Table("ContactTransfer", Schema = "Pending")]
    public class ContactTransfer : ExpirableTableEntity
    {            

        [JsonIgnore]
        [ForeignKey(nameof(Id))]
        public Account RelevantAccount { get; set; } = null!; 

        [Column("NewContact")]
        [Required]
        public string NewContact {  get; set; } = string.Empty;   

        [Column("OldCodeSalt")]
        public string OldCodeSalt { get; set; } = string.Empty;

        [Column("OldCodeHash")]
        public string OldCodeHash { get; set; } = string.Empty;
    
        [Column("NewCodeSalt")]
        public string NewCodeSalt { get; set; } = string.Empty;

        [Column("NewCodeHash")]
        public string NewCodeHash { get; set; } = string.Empty;
       

    }
}
