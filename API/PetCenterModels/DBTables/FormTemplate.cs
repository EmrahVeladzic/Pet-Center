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
    [Table("FormTemplate", Schema = "Business")]
    public class FormTemplate : BaseTableEntity
    {
        [Column("FormDescription")]
        public string? Description {get; set;}

        [NotMapped]
        public List<FormTemplateField>? Entries {get; set;}
        
    }
}
