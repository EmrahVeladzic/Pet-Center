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
    [Table("Wishlist", Schema = "Offer")]
    public class Wishlist : BaseTableEntity
    {
       
        [Column("UserID")]
        public Guid UserId { get; set; }

        [Column("Term")]
        public string Term { get; set; } = string.Empty;

    }
}
