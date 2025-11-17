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
        public int AccountId { get; set; }

        [ForeignKey(nameof(AccountId))]
        [JsonIgnore]
        public Account? UserAccount { get; set; }

        [Column("UserName")]
        public string? UserName { get; set; }

        [Column("ImageID")]
        [JsonIgnore]
        public int? ImageId { get; set; }

        [ForeignKey(nameof(ImageId))]
        public Image? Image { get; set; }
    }
}
