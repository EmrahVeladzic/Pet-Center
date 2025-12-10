using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.DBTables
{
    public class Comment : BaseTableEntity
    {
        public Guid? PosterID { get; set; }
        [ForeignKey(nameof(PosterID))]
        public User? Poster {  get; set; }
        public string? Message { get; set; }
        public DateTime PostDate { get; set; }
        public bool Edited { get; set; }
        public Guid? ReplyingTo { get; set; }
        public Guid ThreadId { get; set; }

    }
}
