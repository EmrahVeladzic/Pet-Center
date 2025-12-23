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
    [Table("MedicalProcedure",Schema ="Service")]
    public class Procedure:BaseTableEntity
    {
        

        [Column("ProcedureDescription")]
        public string? Description {get; set;}


    }
}
