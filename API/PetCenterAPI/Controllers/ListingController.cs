using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ListingController : ControllerTemplate<Listing,ListingSearchObject,ListingRequestDTO,ListingResponseDTO,IListingService>
    {
        public ListingController(IListingService s):base(s) { }
       
       

        [Authorize(Roles ="Employee")]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] ListingRequestDTO ent)
        {
            return await base.Put(id, ent);
        }
        
        [Authorize(Roles ="Employee")]
        [HttpPost]
        public override async Task<IActionResult> Post([FromBody] ListingRequestDTO ent)
        {
            return await base.Post(ent);
        }

        [Authorize(Roles ="Owner,Admin,Employee")]
        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            return await base.Delete(id);
        }


        [Authorize(Roles ="Owner,Admin")]
        [HttpPost("Evaluate/{id}")]
        public async Task<IActionResult> Evaluate([FromRoute]Guid id,[FromQuery]bool approve,[FromQuery]string note="Evaluated")
        {
            return ResultConverter.Convert<object>(await service.Evaluate(id,approve,note));
        }

        [Authorize(Roles ="Owner,Admin")]
        [HttpPost("Discount/{id}")]
        public async Task<IActionResult> Discount([FromRoute]Guid id,[FromQuery] byte percentage, [FromQuery] byte days_valid)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<DiscountResponseSubDTO>(await service.SetDiscount(user_id,id,percentage,days_valid));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="Employee")]
        [HttpPut("Visibility/{id}")]
        public async Task<IActionResult> SetVisibility([FromRoute] Guid id, [FromQuery] bool visible)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<object>(await service.SetVisibility(user_id,id,visible));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="Employee")]
        [HttpPut("Available/{listing_id}/{facility_id}")]
        public async Task<IActionResult> SetAvailability([FromRoute] Guid listing_id,[FromRoute] Guid facility_id, [FromQuery] bool add_remove)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<AvailabilityResponseSubDTO>(await service.SetAvailability(user_id,listing_id,facility_id,add_remove));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="Employee,User")]
        [HttpPut("Report/{listing_id}")]
        public async Task<IActionResult> ReportMisuse([FromRoute] Guid listing_id,[FromQuery] Guid? comment_id, [FromQuery] string Reason)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<ReportResponseSubDTO>(await service.ReportMisuse(user_id,listing_id,comment_id,Reason));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="User")]
        [HttpPut("Review/{listing_id}")]
        public async Task<IActionResult> AddReview([FromRoute] Guid listing_id,[FromQuery] string comment)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<CommentResponseSubDTO>(await service.SendReview(user_id,listing_id,comment));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="Owner,Admin,User")]
        [HttpDelete("Review/{comment_id}")]
        public async Task<IActionResult> RemoveReview([FromRoute] Guid comment_id)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<object>(await service.RemoveReview(user_id,comment_id,SpecifySearchAuthority()));
            }
            return StatusCode(401,"Invalid token.");
        }

    }

}
