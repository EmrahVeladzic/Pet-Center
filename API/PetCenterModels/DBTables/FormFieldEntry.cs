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
    [Table("FormFieldEntry", Schema = "Pending")]
    public class FormFieldEntry : BaseTableEntity
    {
        [Column("FormID")]
        public Guid FormId { get; set; }

        [Column("FormTemplateFieldID")]
        public Guid FormTemplateFieldId { get; set; }

        [Column("Serialized")]
        public string? Serialized {get; set;}

    }
}
