using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.ModelUtils;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using PetCenterAPI;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ListingController : ControllerTemplate<Listing,ListingSearchObject,ListingRequestDTO,ListingResponseDTO,IListingService>
    {
        public ListingController(IListingService s):base(s) { }
       
        
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById([FromRoute] Guid id, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return ResultConverter.Convert<ListingResponseDTO>(await service.GetById(session,user_id,id,SpecifySearchAuthority(),FileScope.Invalid));
        }

        [Authorize(Roles ="Employee")]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] ListingRequestDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return await base.Put(id, ent, user_id, session);
        }
        
        [Authorize(Roles ="Employee")]
        [HttpPost]
        public override async Task<IActionResult> Post([FromBody] ListingRequestDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return await base.Post(ent, user_id, session);
        }

        [Authorize(Roles ="Owner,Admin,Employee")]
        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id, [UserId] Guid user_id)
        {
            return await base.Delete(id, user_id);
        }


        [Authorize(Roles ="Owner,Admin")]
        [HttpPost("Evaluate/{id}")]
        public async Task<IActionResult> Evaluate([FromRoute]Guid id,[FromQuery]bool approve,[FromBody]TextPayloadDTO note, [UserId] Guid user_id)
        {

            if(!approve && (string.IsNullOrWhiteSpace(note.Text)||note.Text.Length>150))
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"The reason is needed when denying listings and needs to be under 150 characters.");
            }

            return ResultConverter.Convert<object>(await service.Evaluate(user_id,id,approve,note.Text));

            
        }

        [Authorize(Roles ="Employee")]
        [HttpPost("Discount/{id}")]
        public async Task<IActionResult> Discount([FromRoute]Guid id,[FromQuery] byte percentage, [FromQuery] byte days_valid, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<DiscountResponseSubDTO>(await service.SetDiscount(user_id,id,percentage,days_valid));
        }

        [Authorize(Roles ="Employee")]
        [HttpPut("Visibility/{id}")]
        public async Task<IActionResult> SetVisibility([FromRoute] Guid id, [FromQuery] bool visible, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<object>(await service.SetVisibility(user_id,id,visible));
        }

      

        [Authorize(Roles ="Employee")]
        [HttpPut("Available/{listing_id}/{facility_id}")]
        public async Task<IActionResult> SetAvailability([FromRoute] Guid listing_id,[FromRoute] Guid facility_id, [FromQuery] bool add_remove, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<AvailabilityResponseSubDTO>(await service.SetAvailability(user_id,listing_id,facility_id,add_remove));
        }

        [Authorize(Roles ="Employee,User")]
        [HttpPost("Report/{listing_id}")]
        public async Task<IActionResult> ReportMisuse([FromRoute] Guid listing_id,[FromQuery] Guid? comment_id, [FromBody] TextPayloadDTO Reason, [UserId] Guid user_id)
        {
            if (string.IsNullOrWhiteSpace(Reason.Text))
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"You need to provide a reason.");
            }
            if (Reason.Text.Length > 255)
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"The stated reason is too long.");
            }
            return ResultConverter.Convert<ReportResponseSubDTO>(await service.ReportMisuse(user_id,listing_id,comment_id,Reason.Text,SpecifySearchAuthority()));
        }

        [Authorize(Roles ="User")]
        [HttpPut("Review/{listing_id}")]
        public async Task<IActionResult> AddReview([FromRoute] Guid listing_id,[FromBody] TextPayloadDTO comment, [UserId] Guid user_id)
        {
            if (string.IsNullOrWhiteSpace(comment.Text) || comment.Text.Length > 150)
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"The text is required and needs to be under 150 characters.");
            }
            return ResultConverter.Convert<CommentResponseSubDTO>(await service.SendReview(user_id,listing_id,comment.Text));
        }

        [Authorize(Roles ="Owner,Admin,User")]
        [HttpDelete("Review/{comment_id}")]
        public async Task<IActionResult> RemoveReview([FromRoute] Guid comment_id, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<object>(await service.RemoveReview(user_id,comment_id,SpecifySearchAuthority()));
        }

    }

}