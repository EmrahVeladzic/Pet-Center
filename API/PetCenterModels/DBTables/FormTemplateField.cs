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
    public enum DataType : byte
    {
        String = 0,
        Integer = 1,       
        Double = 2,
        Boolean = 3,
        DateTime = 4
    }

    [Table("FormTemplateField", Schema = "Business")]
    public class FormTemplateField : BaseTableEntity
    {
        [Column("FormTemplateID")]
        public Guid FormTemplateId { get; set; }

        [Column("FormFieldDescription")]
        public string? Description {get; set;}

        [Column("DataType")]
        public DataType DataType {get; set;}
       
        [Column("Optional")]
        public bool Optional {get; set;}
        
    }
}
