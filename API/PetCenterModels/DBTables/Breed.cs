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

    public enum AnimalScale : byte
    {
        Small = 0,
        Medium = 1,
        Large = 2
    }

    public enum AnimalDiet : byte
    {
        Herbivore = 0x1,
        Carnivore = 0x2,
        Omnivore = 0x3
    }

    [Table("Breed",Schema ="Animal")]
    public class Breed:BaseTableEntity
    {
        [Column("Title")]
        public string? Title {get; set;}

        [Column("KindID")]
        public Guid KindId {get; set;}

        [Column("Scale")]
        public AnimalScale Scale {get; set;}

        [Column("Diet")]
        public AnimalDiet Diet {get; set;}

        [Column("Investment")]
        public float Investment {get; set;}

        [Column("Territory")]
        public float Territory {get; set;}

        [Column("Pricing")]
        public float Pricing {get; set;}

        [Column("Longevity")]
        public float Longevity {get; set;}
        
        [Column("Cohabitation")]
        public float Cohabitation {get; set;}

        [Column("AlbumID")]
        public Guid AlbumId {get; set;}

        [ForeignKey(nameof(AlbumId))]
        public Album? Album {get; set;}

    }
}
