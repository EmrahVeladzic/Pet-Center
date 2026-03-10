using Microsoft.VisualBasic;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.SearchObjects;

namespace PetCenterModels.DataTransferObjects
{
    public class BreedDTO : ISerializableRequestDTO<Breed>, IAlbumCarryingDTO<Breed,BreedDTO>
    {
       
        public Guid? Id {get; set;} = null;
        
        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public Guid KindId {get; set;} = Guid.Empty;

        public AnimalScale Scale {get; set;}

        public float Investment {get; set;} = 0.0f;
        public float Territory {get; set;} = 0.0f;
        public float Pricing {get; set;} = 0.0f;
        public float Longevity {get; set;} = 0.0f;
        public float Cohabitation {get; set;} = 0.0f;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public string Title {get; set;} = string.Empty;

        public Guid AlbumId {get; set;} = Guid.Empty;

        public List<ImageDTO> Images {get; set;} = new();


        public static BreedDTO? FromEntity(Breed? entity)
        {
            if(entity==null){return null;}
            BreedDTO output = new BreedDTO
            {
                Id = entity.Id,
                CurrentVersion=entity.CurrentVersion,
                Title = entity.Title,
                KindId=entity.KindId,
                AlbumId=entity.AlbumId,
                Investment=entity.Investment,
                Territory=entity.Territory,
                Pricing=entity.Pricing,
                Longevity=entity.Longevity,
                Cohabitation=entity.Cohabitation,
                Scale=entity.Scale
            };

            if (entity.Album != null)
            {
                output.Images = entity.Album.Images.Select(i=>ImageDTO.FromEntity(i)!).ToList();
            }

            return output;
        }

        public Breed? ToEntity()
        {
            Breed breed = new();
            breed.CurrentVersion=CurrentVersion;
            breed.KindId=KindId;
            breed.AlbumId=AlbumId;
            breed.Scale=Scale;
            breed.Investment=Investment;
            breed.Territory=Territory;
            breed.Cohabitation=Cohabitation;
            breed.Longevity=Longevity;
            breed.Pricing=Pricing;
            breed.Title=Title;
            return breed;
        }
        
        
        public bool Validate()
        {
            Investment = Math.Clamp(Investment,0.0f,1.0f);
            Territory = Math.Clamp(Territory,0.0f,1.0f);
            Pricing = Math.Clamp(Pricing,0.0f,1.0f);
            Longevity = Math.Clamp(Longevity,0.0f,1.0f);
            Cohabitation = Math.Clamp(Cohabitation,0.0f,1.0f);
            return !string.IsNullOrWhiteSpace(Title);
        }



    }
}
