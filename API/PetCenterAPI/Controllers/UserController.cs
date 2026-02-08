using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
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

        [HttpGet("SetEmployee{usr_id}/{franchise_id}")]
        [Authorize(Roles = "BusinessAccount")]
        public async Task<IActionResult> SetEmployee([FromRoute] Guid usr_id, [FromRoute] Guid franchise_id, [FromQuery] bool add_remove)
        {
            if(TryGetUserId(out Guid caller_id))
            {
                return ResultConverter.Convert<string>(await service.SetEmployee(caller_id,usr_id,franchise_id,add_remove));
            }
            return StatusCode(401,"Invalid token.");  
        }

       
    }

}
