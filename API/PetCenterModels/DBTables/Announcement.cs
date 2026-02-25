using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    [Table("Announcement", Schema = "Communication")]
    public class Announcement : ExpirableTableEntity
    {
        
        [Column("AnnouncementBody")]
        public string Body { get; set; } = string.Empty;

        [Column("UserVisible")]
        public bool UserVisible { get; set; } = false;

        [Column("BusinessVisible")]
        public bool BusinessVisible { get; set; } = false;
     
    }
}
