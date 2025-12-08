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
        public int PosterID { get; set; }
        [ForeignKey(nameof(PosterID))]
        public User? Poster {  get; set; }
        public string? Message { get; set; }
        public DateTime PostDate { get; set; }
        public bool Edited { get; set; }
        public int? ReplyingTo { get; set; }

    }
}
