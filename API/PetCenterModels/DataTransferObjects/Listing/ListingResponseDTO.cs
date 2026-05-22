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
    public class ListingResponseDTO : IAlbumCarryingDTO<Listing,ListingResponseDTO,ImageDTO,Image,ImageMetadata>
    {
       
        public Guid? Id {get; set;} = null;      

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid AlbumId {get; set;} = Guid.Empty;

        public bool Approved {get; set;} = false;

        public bool Visible {get; set;} = false;

        public List<ImageDTO> Media {get; set;} = new();

        public bool Locked {get; set;} = true;

        public string Name {get; set;} = string.Empty;

        public string Description {get; set;} = string.Empty;

        public Guid FranchiseId {get; set;} = Guid.Empty;

        public string Contact {get; set;} = string.Empty;

        public string FranchiseName {get; set;} = string.Empty;

        public long PriceMinor {get; set;} = 0;

        public bool Full {get; set;}=true;

        public ListingType Type  {get; set;} = ListingType.Generic;

        public ProductListingSubDTO? ProductListingExtension {get;set;} = null;
        public MedicalListingSubDTO? MedicalListingExtension {get; set;} = null;
        public AnimalListingSubDTO? AnimalListingExtension {get; set;} = null;

        public DiscountResponseSubDTO? ListingDiscount {get; set;} =null;

        public List<AvailabilityResponseSubDTO> Availability {get; set;} = new();

        public List<CommentResponseSubDTO> Comments {get; set;} = new();

        public DateTime Posted {get; set;} = DateTime.UtcNow;

        public string? MediaCreationToken {get; set;} = string.Empty;

        public static ListingResponseDTO? FromEntity(Listing? entity)
        {
            if(entity==null){return null;}
            ListingResponseDTO output = new ListingResponseDTO
            {
                Id = entity.Id,
                CurrentVersion=entity.CurrentVersion,
                Name=entity.ListingName,
                Description=entity.ListingDescription,
                FranchiseId=entity.FranchiseId,
                Contact="No provided contact.",
                FranchiseName="No provided name.",
                PriceMinor=entity.PriceMinor,
                Type=entity.Type,
                Approved=entity.Approved,
                Visible=entity.Visible,
                AlbumId=entity.AlbumId,
                ProductListingExtension=ProductListingSubDTO.FromEntity(entity.ProductExtension),
                MedicalListingExtension=MedicalListingSubDTO.FromEntity(entity.MedicalExtension),
                AnimalListingExtension=AnimalListingSubDTO.FromEntity(entity.AnimalExtension),
                ListingDiscount=DiscountResponseSubDTO.FromEntity(entity.ListingDiscount),
                Availability=entity.AvailabilityRecords.Select(a=>AvailabilityResponseSubDTO.FromEntity(a)!).ToList(),
                Comments=entity.Comments.Select(c=>CommentResponseSubDTO.FromEntity(c)!).ToList(),
                Posted=entity.Posted
            };

            if (entity.Business != null)
            {
                output.Contact=entity.Business.Contact??output.Contact;
                output.FranchiseName=entity.Business.FranchiseName??output.FranchiseName;
            }

            if (entity.Album != null)
            {
                output.Locked=entity.Album.Locked;
                output.Media = entity.Album.Images.Select(i=>ImageDTO.FromEntity(i)!).ToList();
                output.Full=entity.Album.Reserved>=entity.Album.Capacity;
            }

            return output;
        }


        public static ListingResponseDTO? FromEntity(Listing? entity, string token)
        {
            ListingResponseDTO? output = FromEntity(entity);

            if (output != null)
            {
                output.MediaCreationToken=token;
            }


            return output;
        }


    }
}
