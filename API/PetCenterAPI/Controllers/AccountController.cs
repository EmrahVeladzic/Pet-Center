using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using System.Security.Claims;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerTemplate<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO,IAccountService>
    {

        public AccountController(IAccountService s):base(s) { }

        [HttpPost]
        [AllowAnonymous]
        public override async Task<IActionResult> Post([FromBody] AccountRequestDTO req)
        {
            return ResultConverter.Convert<AccountResponseDTO>(await service.Post(req));
        }


        [HttpPost("LogIn")]
        [AllowAnonymous]
        public async Task<IActionResult> LogIn([FromBody] AccountRequestDTO req)
        {
            return ResultConverter.Convert<string>(await service.LogIn(req));
        }


        [HttpPut]
        [Authorize]
        public override async Task<IActionResult> Put([FromBody] AccountRequestDTO req)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid id);
            if (validGuid)
            {
                req.Id = id;
                return ResultConverter.Convert<AccountResponseDTO>(await service.Put(req));
            }
            return StatusCode(400,"Invalid ID provided.");
        }

        [HttpGet ("RequestVerification")]
        [Authorize]
        public async Task<IActionResult> RequestVerification()
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid id);
            if (validGuid)
            {
                return ResultConverter.Convert<string>(await service.RequestAccountVerification(id));
            }
            return StatusCode(400,"Invalid ID provided.");
        }

        [HttpPost("Verify/{code}")]
        [Authorize]
        public async Task<IActionResult> Verify([FromRoute] int code)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid id);

            if (validGuid)
            {           
                return ResultConverter.Convert<string>(await service.VerifyAccount(id,code));
            }
            return StatusCode(400,"Invalid ID provided.");
        }

        [HttpPut("SetRole/{id}/{role}")]
        [Authorize(Roles ="Owner")]
        public async Task<IActionResult> SetRole([FromRoute] Guid id, [FromRoute] Access role)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid owner_id);

            if(validGuid && await service.CheckIsAuthorizedToModify(owner_id, id))
            {
                return ResultConverter.Convert<string>(await service.SetRole(id,role));
            }

            return StatusCode(403, "This action is not allowed.");

        }

        [HttpDelete("{id}")]
        [Authorize]
        public override async Task<IActionResult> Delete([FromRoute]Guid id)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid usr_id);

            if (validGuid && !await service.CheckIsLastOwner(usr_id) && id==usr_id)
            {
                return ResultConverter.Convert<object>(await service.Delete(usr_id));
            }

            return StatusCode(403, "This action is not allowed.");
            
        }


        [HttpDelete("Ban/{id}")]
        [Authorize (Roles ="Owner,Admin")]
        public async Task<IActionResult> Ban([FromRoute] Guid id)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid admin_id);

            if (validGuid && await service.CheckIsAuthorizedToModify(admin_id,id))
            {
                return ResultConverter.Convert<object>(await service.Delete(id));
            }

            return StatusCode(401, "You are not authorized to ban this user.");
           
        }



    }

}
