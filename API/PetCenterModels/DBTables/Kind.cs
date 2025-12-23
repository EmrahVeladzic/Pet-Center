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
    [Table("Kind",Schema ="Animal")]
    public class Kind:BaseTableEntity
    {
        [Column("Title")]
        public string? Title {get; set;}


        [Column("AlbumID")]
        public Guid AlbumId {get; set;}

        [ForeignKey(nameof(AlbumId))]
        public Album? Album {get; set;}

    }
}
