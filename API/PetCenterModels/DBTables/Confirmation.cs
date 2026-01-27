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
    [Table("Confirmation", Schema = "Pending")]
    public class Confirmation : ExpirableTableEntity
    {
        [Column("UserID")]
        public Guid UserId { get; set; }

        [Column("ListingID")]
        public Guid ListingId { get; set; }

     

    }
}
