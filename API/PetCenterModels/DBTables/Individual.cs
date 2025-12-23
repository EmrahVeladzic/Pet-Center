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

    [Table("Individual",Schema ="Animal")]
    public class Individual:BaseTableEntity
    {
        [Column("BreedID")]
        public Guid BreedId {get; set;}

        [Column("AnimalName")]
        public string? Name {get; set;}

        [Column("BirthDate")]
        public DateTime BirthDate {get; set;}

        [Column("AlbumID")]
        public Guid AlbumId {get; set;}

        [Column("Sex")]
        public bool Sex {get; set;}

        [ForeignKey(nameof(AlbumId))]
        public Album? Album {get; set;}

    }
}
