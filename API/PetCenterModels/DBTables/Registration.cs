using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    [Table("Registration", Schema = "Pending")]
    public class Registration
    {
        [Key]
        [Column("AccountID")]
        public int AccountID { get; set; }

        [JsonIgnore]
        [ForeignKey(nameof(AccountID))]
        public Account? RelevantAccount { get; set; }

        [Column("Code")]
        public int Code { get; set; }

        [Column("Expiry")]
        public DateTime Expiry {  get; set; }


        [Column("NextAttempt")]
        public DateTime NextAttempt { get; set; }

    }
}
