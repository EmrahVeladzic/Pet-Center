using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Utils;

namespace PetCenterServices.Interfaces
{
    public interface IListingService : IBaseCRUDService<Listing,ListingSearchObject,ListingRequestDTO,ListingResponseDTO>
    {        
        public Task <ServiceOutput<ReportResponseSubDTO>> ReportMisuse(Guid token_holder, Guid ListingId, Guid? CommentId, string Reason);
        public Task <ServiceOutput<CommentResponseSubDTO>> SendReview(Guid token_holder, Guid ListingId, string message);
        public Task <ServiceOutput<object>> RemoveReview(Guid token_holder, Guid comment_id, Access authorization_level);
        public Task <ServiceOutput<DiscountResponseSubDTO>> SetDiscount(Guid token_holder, Guid ListingId, byte percentage, byte days_valid);
        public Task <ServiceOutput<object>> SetVisibility(Guid token_holder, Guid ListingId, bool visible);
        public Task <ServiceOutput<object>> Evaluate (Guid ListingId,bool approved,string note);
        public Task <ServiceOutput<AvailabilityResponseSubDTO>> SetAvailability(Guid token_holder, Guid ListingId, Guid FacilityId, bool add_remove);
    }
}