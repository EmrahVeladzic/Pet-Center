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
    [Table("Album", Schema = "File")]
    public class Album : BaseTableEntity
    {
        [Column("Capacity")]
        public byte Capacity { get; set; }

        [Column("Reserved")]
        public byte Reserved { get; set; }


        [NotMapped]
        public List<Image>? Images { get; set; }
    }
}
