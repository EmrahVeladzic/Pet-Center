using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Thread : BaseTableEntity
    {
        public string? Title { get; set; }
        public string? Description { get; set; }    
        public int OriginalPosterId {  get; set; }

        [ForeignKey(nameof(OriginalPosterId))]
        public User? OriginalPoster { get; set; }
        public DateTime CreationTime { get; set; }
        public bool Edited { get; set; }
    }
}
