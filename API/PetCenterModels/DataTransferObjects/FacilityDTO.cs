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

namespace PetCenterModels.DataTransferObjects
{
    public class FacilityDTO : ISerializableRequestDTO<Facility>, IBaseResponseDTO<Facility,FacilityDTO>
    {
       
        public Guid? Id {get; set;} = null;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid OwningFranchise {get; set;} = Guid.Empty;

        public string Street {get; set;} = string.Empty;

        public string City {get; set;} = string.Empty;

        public string? Contact {get; set;} = null;


        public static FacilityDTO? FromEntity(Facility? entity)
        {
            if(entity==null){return null;}
            return new FacilityDTO
            {
                Id = entity.Id,
                Street = entity.Street,
                City = entity.City,
                Contact = entity.Contact,
                OwningFranchise = entity.FranchiseId
            };
        }

        public Facility? ToEntity()
        {
            Facility facility = new();
           
            facility.Contact=Contact;
            facility.FranchiseId=OwningFranchise;
            facility.City=City;
            facility.Street=Street;

            return facility;
        }

        public bool Validate()
        {
            Contact=Contact?.ToLowerInvariant();
            EmailAddressAttribute e = new();
            return(e.IsValid(Contact)&&!string.IsNullOrWhiteSpace(City)&&!string.IsNullOrWhiteSpace(Street)&&!(OwningFranchise==Guid.Empty));
        }



    }
}
