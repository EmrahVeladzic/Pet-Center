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

        [ForeignKey(nameof(ProcedureId))]
        public Procedure MedicalProcedure {get; set;} = null!;

        [Column("AnimalID")]
        public Guid AnimalId {get; set;}

        [ForeignKey(nameof(AnimalId))]
        public Individual Animal {get; set;} = null!;

        [Column("DatePerformed")]
        public DateTime DatePerformed {get; set;}

    }
}
