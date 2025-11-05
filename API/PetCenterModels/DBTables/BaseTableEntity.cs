using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class BaseTableEntity
    {
        [Key]
        public int Id { get; set; }

        public BaseTableEntity()
        {
            
        }

    }
}
