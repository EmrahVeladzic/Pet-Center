using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;

namespace PetCenterModels.DataTransferObjects
{

    public class FranchiseResponseDTO : IBaseResponseDTO<Franchise,FranchiseResponseDTO> 
    {
        public Guid? Id { get; set; }

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();
        public string? FranchiseName { get; set; }
        public string? Contact { get; set; }   

        public List<FacilityDTO> Facilities {get; set;} = new List<FacilityDTO>();

        public List<NoteSubDTO>? Notes {get; set;}

        public bool? Owned {get; set;} = null;

        public static FranchiseResponseDTO? FromEntity(Franchise? model)
        {
            if(model==null){return null;}

            return new FranchiseResponseDTO
            {
                Id = model.Id,
                CurrentVersion=model.CurrentVersion,
                FranchiseName = model.FranchiseName,
                Contact = model.Contact,
                Facilities = model.Facilities.Select(e=>FacilityDTO.FromEntity(e)!).ToList()
            };

            
        }


        public static FranchiseResponseDTO? FromEntity(Franchise? model, bool owned)
        {
            if(model==null){return null;}

            FranchiseResponseDTO output = new FranchiseResponseDTO
            {
                Id = model.Id,
                CurrentVersion=model.CurrentVersion,
                FranchiseName = model.FranchiseName,
                Contact = model.Contact,  
                Owned = owned,
                
                         
            };

            if (output.Owned==true)
            {
                output.Facilities = model.Facilities.Select(e=>FacilityDTO.FromEntity(e)!).ToList();
            }

            return output;
        }
    }

}