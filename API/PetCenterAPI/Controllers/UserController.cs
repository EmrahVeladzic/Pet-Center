using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerTemplate<User,UserSearchObject,UserRequestDTO,UserResponseDTO,IUserService>
    {

        public UserController(IUserService s):base(s) { }

        [HttpGet("me")]
        public async Task<IActionResult> GetSelf()
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<UserResponseDTO>(await service.GetById(user_id,user_id,SpecifySearchAuthority()));
            }
            return StatusCode(401,"Invalid token.");  
        }


        [HttpPut("SetEmployee/{usr_id}/{franchise_id}")]
        [Authorize(Roles = "BusinessAccount")]
        public async Task<IActionResult> SetEmployee([FromRoute] Guid usr_id, [FromRoute] Guid franchise_id, [FromQuery] bool add_remove)
        {
            if(TryGetUserId(out Guid caller_id))
            {
                return ResultConverter.Convert<string>(await service.SetEmployee(caller_id,usr_id,franchise_id,add_remove));
            }
            return StatusCode(401,"Invalid token.");  
        }


        [HttpPut("SetTerm/{term}")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> SetWishlistTerm([FromRoute] string term, [FromQuery] bool add_remove)
        {
            if(TryGetUserId(out Guid caller_id))
            {
                return ResultConverter.Convert<string>(await service.SetWishlistTerm(caller_id,term,add_remove));
            }
            return StatusCode(401,"Invalid token.");  
        }


        [HttpPut("Announcement")]
        [Authorize(Roles = "Owner,Admin")]
        public async Task<IActionResult> AddAnnouncement([FromBody] string announcement, [FromQuery] bool user_visible, [FromQuery] bool business_visible, [FromQuery]  int days_valid = 7)
        {
            return ResultConverter.Convert<AnnouncementSubDTO>(await service.AddAnnouncement(announcement,user_visible,business_visible,days_valid));
        }
        
        [HttpDelete("Announcement/{announcement_id}")]
        [Authorize(Roles = "Owner,Admin")]
        public async Task<IActionResult> RemoveAnnouncement([FromRoute] Guid announcement_id)
        {
            
            return ResultConverter.Convert<string>(await service.RemoveAnnouncement(announcement_id));
             
        }

        [HttpPut("Notification/{usr_id}")]
        [Authorize(Roles = "Owner,Admin")]
        public async Task<IActionResult> AddAnnouncement([FromRoute] Guid usr_id, [FromBody] string title, [FromBody] string body, [FromQuery] Guid? franchise_id, [FromQuery] Guid? listing_id, [FromQuery] int days_valid = 7)
        {
            return ResultConverter.Convert<NotificationSubDTO>(await service.AddNotification(title,body,usr_id,franchise_id,listing_id,days_valid));
        }

        
        [HttpDelete("Notification/{announcement_id}")]
        [Authorize(Roles = "Owner,Admin")]
        public async Task<IActionResult> RemoveNotification([FromRoute] Guid notification_id)
        {
            
            return ResultConverter.Convert<string>(await service.RemoveNotification(notification_id));
             
        }
       
    }

}
