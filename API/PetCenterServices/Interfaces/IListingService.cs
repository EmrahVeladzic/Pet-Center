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

        /*
        public ServiceOutput<Task<ReportResponseSubDTO>> ReportMisuse(Guid token_holder, Guid ListingId, Guid? CommentId, string Reason);
        public ServiceOutput<Task<CommentResponseSubDTO>> SendReview(Guid token_holder, Guid ListingId, string message);
        public ServiceOutput<Task<object>> RemoveReview(Guid token_holder, Guid comment_id);
        public ServiceOutput<Task<DiscountResponseSubDTO>> SetDiscount(Guid token_holder, Guid ListingId, int percentage, int days_valid);
        public ServiceOutput<Task<object>> SetVisibility(Guid token_holder, Guid ListingId, bool visible);
        public ServiceOutput<Task<object>> Approve (Guid ListingId);
*/

    }
}