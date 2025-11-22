using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class BaseTableEntity
    {
        [Key]
        [Column("ID")]
        public int Id { get; set; }

        public BaseTableEntity()
        {
            
        }

    }
}
