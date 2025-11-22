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
    [Table("File", Schema = "Album")]
    public class Album : BaseTableEntity
    {
        [NotMapped]
        public List<Image>? Images { get; set; }
    }
}
