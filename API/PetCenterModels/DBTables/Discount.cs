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
    public class Discount : ExpirableTableEntity
    {
        [Column("ListingID")]
        public Guid? ListingId { get; set; }

        [Column("PercentDiscount")]
        public byte PercentDiscount { get; set; }


    }
}
