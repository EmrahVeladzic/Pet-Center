using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;

namespace PetCenterModels.Requests
{

    public class FranchiseResponseDTO : IBaseResponseDTO<Franchise,FranchiseResponseDTO> , IAlbumCarryingDTO
    {
        public Guid? Id { get; set; }
        public string? FranchiseName { get; set; }
        public string? Contact { get; set; }
    
        public List<ImageDTO> Images { get; set; } = new List<ImageDTO>();

        public static FranchiseResponseDTO? FromEntity(Franchise? model)
        {
            if(model==null){return null;}

            return new FranchiseResponseDTO
            {
                Id = model.Id,
                FranchiseName = model.FranchiseName,
                Contact = model.Contact
            };
        }
    }

}