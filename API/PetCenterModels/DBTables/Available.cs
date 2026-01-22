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
    [Table("Available", Schema = "Offer")]
    public class Available : BaseTableEntity
    {   
        [Column("ListingID")]
        public Guid ListingId { get; set; }

        [Column("FacilityID")]
        public Guid FacilityId { get; set; }

        [Column("Stock")]
        public byte Stock { get; set; }
    }
    
}
