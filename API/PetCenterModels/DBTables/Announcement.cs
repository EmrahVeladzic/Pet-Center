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
        [Column("RoleSpecific")]
        public Access? RoleSpecific { get; set; }

        [Column("Title")]
        public string Title { get; set; } = string.Empty;

        [Column("Body")]
        public string Body { get; set; } = string.Empty;
     
    }
}
