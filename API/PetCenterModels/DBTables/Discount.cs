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
    [Table("Discount", Schema = "Offer")]
    public class Discount : ExpirableTableEntity
    {
        [Column("ListingID")]
        public Guid ListingId { get; set; }

        [ForeignKey(nameof(ListingId))]
        public Listing RelevantListing {get; set;} = null!;

        [Column("PercentDiscount")]
        public byte PercentDiscount { get; set; }


    }
}
