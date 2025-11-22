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
    public enum Access : byte
    {
        Owner = 255,
        Admin = 1,
        User = 0
    }

    [Table("Account", Schema = "Person")]
    public class Account : BaseTableEntity
    {
        [Column("Contact")]
        [Required]
        public string? Contact {  get; set; }       

        [Column("PasswordHash")]
        [JsonIgnore]
        [Required]
        public string? PasswordHash { get; set; }

        [Column("PasswordSalt")]
        [JsonIgnore]
        public string? PasswordSalt { get; set; }

        [Column("AccessLevel")]
        [JsonIgnore]
        public Access AccessLevel { get; set; }

        [Column("Verified")]
        [JsonIgnore]
        public bool Verified { get; set; }

    }
}
