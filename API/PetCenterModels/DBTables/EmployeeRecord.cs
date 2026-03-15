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
    [Table("EmployeeRecord", Schema = "Business")]
    public class EmployeeRecord : BaseTableEntity
    {
        [Column("UserID")]
        public Guid UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public User Employee{get;set;} = null!;

        [Column("FranchiseID")]
        public Guid FranchiseId { get; set; }

        [ForeignKey(nameof(FranchiseId))]
        public Franchise Business {get;set;} = null!;

        
    }
}
