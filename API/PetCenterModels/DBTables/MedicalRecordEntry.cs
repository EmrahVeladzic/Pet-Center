using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;


namespace PetCenterModels.DBTables
{
    [Table("MedicalRecordEntry",Schema ="Service")]
    public class MedicalRecordEntry:BaseTableEntity
    {

        [Column("ProcedureID")]
        public Guid ProcedureId {get; set;}

        [Column("AnimalID")]
        public Guid AnimalId {get; set;}

        [Column("Notes")]
        public string? Notes {get; set;}

        [Column("DatePerformed")]
        public DateTime DatePerformed {get; set;}

    }
}
