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
    [Table("Report", Schema = "Communication")]
    public class Report : ExpirableTableEntity
    {

        [Column("ListingID")]
        public Guid ListingId { get; set; }

        [Column("CommentID")]
        public Guid? CommentId { get; set; } = null;

        [Column("ReporterID")]
        public Guid ReporterId { get; set; }

        [Column("Reason")]
        public string Reason { get; set; } = string.Empty;


    }
}
