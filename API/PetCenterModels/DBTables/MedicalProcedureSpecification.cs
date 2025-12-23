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
    [Table("MedicalProcedureSpecification",Schema ="Service")]
    public class MedicalProcedureSpecification:BaseTableEntity
    {

        [Column("ProcedureID")]
        public Guid ProcedureId {get; set;}

        [Column("KindID")]
        public Guid KindId {get; set;}

        [Column("BreedID")]
        public Guid? BreedId {get; set;}

        [Column("ApproximateAgeDays")]
        public int? ApproximateAge {get; set;}

        [JsonIgnore]
        [Column("SexSpecific")]
        public bool? SexSpecific {get; set;}


        [NotMapped]
        public string SexSpecifier => SexSpecific switch{
            true=> "Male",
            false=> "Female",
            null => "Both"
        };

        

        [Column("Optional")]
        public bool Optional {get; set;}

    }
}
