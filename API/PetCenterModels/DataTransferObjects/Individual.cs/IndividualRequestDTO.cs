using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.DataTransferObjects
{
    public class IndividualRequestDTO : ISerializableRequestDTO<Individual>
    {       
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        [MaxLength(75)]
        public string Name {get; set;} = string.Empty;

        public Guid BreedId {get; set;} = Guid.Empty;

        public bool Sex {get; set;}

        public DateTime BirthDate {get; set;} = DateTime.UtcNow;

        [JsonIgnore]
        [ReadOnly(true)]
        public Guid? OwnerId {get; set;} = null;

        public Guid? ShelterId {get; set;} = null;
    
        [JsonIgnore]
        [ReadOnly(true)]
        public Access AuthoritySpecifier {get; set;} = Access.User;


        public Individual? ToEntity()
        {
            Individual output = new();
            output.CurrentVersion=CurrentVersion;
            output.AnimalIdentity = Guid.NewGuid();
            output.BreedId=BreedId;
            output.Sex=Sex;
            output.BirthDate=BirthDate;
            output.Name=Name;
            if (AuthoritySpecifier == Access.User)
            {
                output.Owned=true;
                output.OwnerId=OwnerId;  
                output.ShelterId=null;              
            }
            else
            {
                output.Owned=false;
                output.OwnerId=null;
                output.ShelterId=ShelterId;
            }

            return output;
        }

        public string? Validate()
        {
            if(AuthoritySpecifier==Access.User){
                ShelterId=null;
                if(OwnerId==null){return "Owner not provided.";}
            }

            if (AuthoritySpecifier == Access.BusinessAccount){
                OwnerId=null;
                if(ShelterId==null){return "Shelter not provided.";}
            }


            return string.IsNullOrWhiteSpace(Name)? "Animal names may not be empty.": null;
        }
    }
}
