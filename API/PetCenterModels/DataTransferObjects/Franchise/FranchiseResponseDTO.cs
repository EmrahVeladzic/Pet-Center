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
        public string? FranchiseName { get; set; }
        public string? Contact { get; set; }
    
        public Guid AlbumId {get; set;}

        public List<ImageDTO?>? Images { get; set; }

        public List<NoteSubDTO>? Notes {get; set;}

        public bool? Owned {get; set;} = null;

        public static FranchiseResponseDTO? FromEntity(Franchise? model)
        {
            if(model==null){return null;}

            return new FranchiseResponseDTO
            {
                Id = model.Id,
                FranchiseName = model.FranchiseName,
                Contact = model.Contact,
            };
        }


        public static FranchiseResponseDTO? FromEntity(Franchise? model, bool owned)
        {
            if(model==null){return null;}

            return new FranchiseResponseDTO
            {
                Id = model.Id,
                FranchiseName = model.FranchiseName,
                Contact = model.Contact,  
                Owned = owned             
            };

          
        }
    }

}