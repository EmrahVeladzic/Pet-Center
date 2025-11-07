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
    public class User : BaseTableEntity
    {       
        [JsonIgnore]
        public int AccountId { get; set; }

        [ForeignKey(nameof(AccountId))]
        [JsonIgnore]
        public Account? UserAccount { get; set; }

        public string? UserName { get; set; }

        [JsonIgnore]
        public int? ImageId { get; set; }

        [ForeignKey(nameof(ImageId))]
        public Image? Image { get; set; }
    }
}
