using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Album
    {
        [Key]
        [JsonIgnore]
        public int Id { get; set; }

        public List<Image>? Images { get; set; }
    }
}
