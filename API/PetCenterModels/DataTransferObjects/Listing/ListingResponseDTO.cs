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
    public class ListingResponseDTO : IAlbumCarryingDTO<Listing,ListingResponseDTO>
    {
       
        public Guid? Id {get; set;} = null;      

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid AlbumId {get; set;} = Guid.Empty;

        public List<ImageDTO> Images {get; set;} = new();

        public string Name {get; set;} = string.Empty;

        public string Description {get; set;} = string.Empty;

        public Guid FranchiseId {get; set;} = Guid.Empty;

        public string Contact {get; set;} = string.Empty;

        public string FranchiseName {get; set;} = string.Empty;

        public long PriceMinor {get; set;} = 0;

        public ListingType Type  {get; set;} = ListingType.Generic;

        public ProductListingSubDTO? ProductListingExtension {get;set;} = null;
        public MedicalListingSubDTO? MedicalListingExtension {get; set;} = null;
        public AnimalListingSubDTO? AnimalListingExtension {get; set;} = null;

        public DiscountResponseSubDTO? ListingDiscount {get; set;} =null;

        public List<AvailabilityResponseSubDTO> Availability {get; set;} = new();

        public List<CommentResponseSubDTO> Comments {get; set;} = new();

        public static ListingResponseDTO? FromEntity(Listing? entity)
        {
            if(entity==null){return null;}
            ListingResponseDTO output = new ListingResponseDTO
            {
                Id = entity.Id,
                Name=entity.ListingName,
                Description=entity.ListingDescription,
                FranchiseId=entity.FranchiseId,
                Contact=entity.Business.Contact??"No provided contact.",
                FranchiseName=entity.Business.FranchiseName??"No provided name.",
                PriceMinor=entity.PriceMinor,
                Type=entity.Type,
                ProductListingExtension=ProductListingSubDTO.FromEntity(entity.ProductExtension),
                MedicalListingExtension=MedicalListingSubDTO.FromEntity(entity.MedicalExtension),
                AnimalListingExtension=AnimalListingSubDTO.FromEntity(entity.AnimalExtension),
                ListingDiscount=DiscountResponseSubDTO.FromEntity(entity.ListingDiscount),
                Availability=entity.AvailabilityRecords.Select(a=>AvailabilityResponseSubDTO.FromEntity(a)!).ToList(),
                Comments=entity.Comments.Select(c=>CommentResponseSubDTO.FromEntity(c)!).ToList()
            };

            if (entity.Album != null)
            {
                output.Images = entity.Album.Images.Select(i=>ImageDTO.FromEntity(i)!).ToList();
            }

            return output;
        }





    }
}
