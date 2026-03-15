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

    public class ProductListingSubDTO : ISerializableRequestDTO<ProductListing>, IBaseResponseDTO<ProductListing,ProductListingSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid ProductId {get; set;} = Guid.Empty;

        public byte PerListing {get; set;} = 1;


        public bool Validate()
        {
            return !(ProductId==Guid.Empty) && (PerListing>0);
        }

        public ProductListing? ToEntity()
        {
            ProductListing output = new();
            output.CurrentVersion=CurrentVersion;
            output.ProductId=ProductId;
            output.PerListing=PerListing;
            return output;   
        }

        public static ProductListingSubDTO? FromEntity(ProductListing? entity)
        {
            if(entity==null){return null;}
            return new ProductListingSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                ProductId=entity.ProductId,
                PerListing=entity.PerListing
            };

        }

    }


    public class AnimalListingSubDTO : ISerializableRequestDTO<AnimalListing>, IBaseResponseDTO<AnimalListing,AnimalListingSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid AnimalId {get; set;} = Guid.Empty;


        public bool Validate()
        {
            return !(AnimalId==Guid.Empty);
        }

        public AnimalListing? ToEntity()
        {
            AnimalListing output = new();
            output.CurrentVersion=CurrentVersion;
            output.AnimalId=AnimalId;
            return output;   
        }

        public static AnimalListingSubDTO? FromEntity(AnimalListing? entity)
        {
            if(entity==null){return null;}
            return new AnimalListingSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                AnimalId = entity.AnimalId
            };

        }

    }


    public class MedicalListingSubDTO : ISerializableRequestDTO<MedicalListing>, IBaseResponseDTO<MedicalListing,MedicalListingSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public Guid ProcedureId {get; set;} = Guid.Empty;


        public bool Validate()
        {
            return !(ProcedureId==Guid.Empty);
        }

        public MedicalListing? ToEntity()
        {
            MedicalListing output = new();
            output.CurrentVersion=CurrentVersion;
            output.ProcedureId=ProcedureId;
            return output;   
        }

        public static MedicalListingSubDTO? FromEntity(MedicalListing? entity)
        {
            if(entity==null){return null;}
            return new MedicalListingSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                ProcedureId = entity.ProcedureId
            };

        }

    }


    public class CommentResponseSubDTO : IBaseResponseDTO<Comment, CommentResponseSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public Guid PosterId {get; set;} = Guid.Empty;

        public string PosterName {get; set;} = string.Empty;

        public string Contents {get; set;} = string.Empty;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static CommentResponseSubDTO? FromEntity(Comment? entity)
        {
            if(entity==null){return null;}
            CommentResponseSubDTO output = new CommentResponseSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                PosterId=entity.PosterId,
                PosterName="Anonymous",
                Contents=entity.Message
            };

            if (entity.Poster != null)
            {
                output.PosterName=entity.Poster.UserName;
            }

            return output;
        }

    }

    public class AvailabilityResponseSubDTO : IBaseResponseDTO<Available, AvailabilityResponseSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public Guid FacilityId {get; set;}

        public string Contact {get; set;} = string.Empty;

        public string City {get; set;} = string.Empty;

        public string Street {get; set;} = string.Empty;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static AvailabilityResponseSubDTO? FromEntity(Available? entity)
        {
            if(entity==null){return null;}
            AvailabilityResponseSubDTO output = new AvailabilityResponseSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                FacilityId=entity.FacilityId,
                Contact="No contact provided.",
                City=entity.RelevantFacility.City="No city provided.",
                Street=entity.RelevantFacility.Street="No street provided."

            };

            if (entity.RelevantFacility != null)
            {
                if (entity.RelevantFacility.OwningFranchise != null)
                {
                    output.Contact=entity.RelevantFacility.OwningFranchise.Contact;
                }

                output.Contact=entity.RelevantFacility.Contact??output.Contact;
                
                output.City=entity.RelevantFacility.City??output.City;
                output.Street=entity.RelevantFacility.Street??output.Street;
            }

            return output;

        }

    }


    public class DiscountResponseSubDTO : IBaseResponseDTO<Discount, DiscountResponseSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public int Percentage {get; set;} = 0;

        public DateTime Expiry {get; set;} = DateTime.UtcNow;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static DiscountResponseSubDTO? FromEntity(Discount? entity)
        {
            if(entity==null){return null;}
            return new DiscountResponseSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                Percentage=entity.PercentDiscount,
                Expiry=entity.Expiry

            };

        }

    }


    public class ReportResponseSubDTO : IBaseResponseDTO<Report, ReportResponseSubDTO>
    {
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public string Reason {get; set;} = string.Empty;

        public Guid ReporterId {get; set;} = Guid.Empty;

        public Guid ListingId {get; set;} = Guid.Empty;

        public Guid? CommentId {get; set;} = null;

        public DateTime Expiry {get; set;} = DateTime.UtcNow;

        public List<NoteSubDTO>? Notes {get; set;} = null;

        public static ReportResponseSubDTO? FromEntity(Report? entity)
        {
            if(entity==null){return null;}
            return new ReportResponseSubDTO
            {
                Id=entity.Id,
                CurrentVersion=entity.CurrentVersion,
                Reason=entity.Reason,
                ReporterId=entity.ReporterId,
                ListingId=entity.ListingId,
                CommentId=entity.CommentId,
                Expiry=entity.Expiry

            };

        }

    }

}