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
    public class ListingRequestDTO : ISerializableRequestDTO<Listing>
    {       
        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        [MaxLength(75)]
        public string Name {get; set;} = string.Empty;

        [MaxLength(1000)]
        public string Description {get; set;} = string.Empty;

        public Guid FranchiseId {get; set;} = Guid.Empty;

        public long PriceMinor {get; set;} = 0;

        public ListingType Type  {get; set;} = ListingType.Generic;

        public ProductListingSubDTO? ProductListingExtension {get;set;} = null;
        public MedicalListingSubDTO? MedicalListingExtension {get; set;} = null;
        public AnimalListingSubDTO? AnimalListingExtension {get; set;} = null;

      
        public Listing? ToEntity()
        {
            Listing output = new();
            output.CurrentVersion=CurrentVersion;
            output.ListingName=Name;
            output.ListingDescription=Description;
            output.FranchiseId=FranchiseId;
            output.PriceMinor=PriceMinor;
            output.Type=Type;
            
            return output;
        }

        public string? Validate()
        {

            switch (Type)
            {
                case ListingType.Product:{ 
                    MedicalListingExtension=null;
                    AnimalListingExtension=null;
                    if(ProductListingExtension==null){return "Missing product extension for product listing.";}
                    string? val = ProductListingExtension.Validate();
                    if(val!=null){return val;}
                    break;
                }
                case ListingType.Medical:{ 
                    ProductListingExtension=null;
                    AnimalListingExtension=null;
                    if(MedicalListingExtension==null){return "Missing medical extension for medical listing.";}
                    string? val = MedicalListingExtension.Validate();
                    if(val!=null){return val;}
                    break;
                }
                case ListingType.Pet:{ 
                    ProductListingExtension=null;
                    MedicalListingExtension=null;
                    if(AnimalListingExtension==null){return "Missing animal extension for adoption listing.";}
                    string? val = AnimalListingExtension.Validate();
                    if(val!=null){return val;}                     
                    break;                
                }
                default:{
                    MedicalListingExtension=null;
                    ProductListingExtension=null;
                    AnimalListingExtension=null;
                    break;
                }
            }

            if(PriceMinor<0){PriceMinor=0;}

            if(FranchiseId==Guid.Empty){return "No franchise provided.";}

            if(string.IsNullOrWhiteSpace(Description)){return "Listings must have a description.";}


            return string.IsNullOrWhiteSpace(Name)? "Listings must have a title.": null;
        
        }
    }
}
