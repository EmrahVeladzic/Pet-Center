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
    [Table("Notification", Schema = "Communication")]
    public class Notification : ExpirableTableEntity
    {
        [Column("UserID")]
        public Guid UserId { get; set; }

        [Column("FranchiseID")]
        public Guid? FranchiseId { get; set; }

        [Column("Title")]
        public string? Title { get; set; }

        [Column("Body")]
        public string? Body { get; set; }

        [Column("ListingID")]
        public Guid ListingId { get; set; }

      

    }
}
