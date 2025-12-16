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
    [Table("User", Schema = "Person")]
    public class User : BaseTableEntity
    {
        [Column("AccountID")]
        [JsonIgnore]
        public Guid AccountId { get; set; }

        [ForeignKey(nameof(AccountId))]
        [JsonIgnore]
        public Account? UserAccount { get; set; }

        [Column("UserName")]
        public string? UserName { get; set; }

        [Column("ProfilePictureID")]
        [JsonIgnore]
        public Guid? PictureId { get; set; }

        [ForeignKey(nameof(PictureId))]
        public Album? Picture { get; set; }
    }
}
