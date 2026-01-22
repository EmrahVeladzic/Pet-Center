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


        [HttpPost]
        public override async Task<IActionResult> Post([FromBody] UserRequestDTO ent)
        {
            await Task.CompletedTask;
            return StatusCode(501,"Illegal endpoint.");
        }

        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            await Task.CompletedTask;
            return StatusCode(501,"Illegal endpoint.");
        }


    }

}
