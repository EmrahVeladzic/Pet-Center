using System;
using System.Collections.Generic;
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

        public string Name {get; set;} = string.Empty;

        public Guid BreedId {get; set;} = Guid.Empty;

        public bool Sex {get; set;}

        public DateTime BirthDate {get; set;} = DateTime.UtcNow;

        [NotMapped]
        public Guid? OwnerId {get; set;} = null;

        public Guid? ShelterId {get; set;} = null;
    
        [NotMapped]
        public Access? AuthoritySpecifier {get; set;} = Access.User;


        public Individual? ToEntity()
        {
            Individual output = new();
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

        public bool Validate()
        {
            return !string.IsNullOrWhiteSpace(Name) && ((AuthoritySpecifier==Access.User&&ShelterId==null&&OwnerId!=null)||(AuthoritySpecifier==Access.BusinessAccount&&OwnerId==null&&ShelterId!=null));
        }
    }
}
