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

        public string Name {get; set;} = string.Empty;

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
            output.ListingName=Name;
            output.ListingDescription=Description;
            output.FranchiseId=FranchiseId;
            output.PriceMinor=PriceMinor;
            output.Type=Type;
            
            return output;
        }

        public bool Validate()
        {

            switch (Type)
            {
                case ListingType.Product:{ if(ProductListingExtension==null||!ProductListingExtension.Validate()){return false;} break;}
                case ListingType.Medical:{ if(MedicalListingExtension==null||!MedicalListingExtension.Validate()){return false;} break;}
                case ListingType.Pet:{ if(AnimalListingExtension==null||!AnimalListingExtension.Validate()){return false;} break;}
            }


            return (!string.IsNullOrWhiteSpace(Name) && !string.IsNullOrWhiteSpace(Description)&&PriceMinor>=0 && !(FranchiseId==Guid.Empty));
        
        }
    }
}
