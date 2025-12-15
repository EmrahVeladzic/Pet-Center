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
    public class AccountController : ControllerTemplate<Account,AccountSearchObject,IAccountService>
    {

        public AccountController(IAccountService s):base(s) { }

        [HttpPost("Register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] AccountRequestDTO req)
        {
            if (!string.IsNullOrWhiteSpace(req.Password) && (!string.IsNullOrWhiteSpace(req.Contact))){

                if (!await service.CheckIfAccountExists(req))
                {
                    await service.Register(req);

                    if (!await service.CheckIfAccountExists(req))
                    {
                        return StatusCode(400, "Invalid contact, and/or password.");
                    }

                    return StatusCode(201,"Account created.");
                }

                return StatusCode(409,"Account with associated contact already exists.");

            }

            return StatusCode(400,"Invalid contact, and/or password.");
        }

        [HttpPost("LogIn")]
        [AllowAnonymous]
        public async Task<IActionResult> LogIn([FromBody] AccountRequestDTO req)
        {
            if (!string.IsNullOrWhiteSpace(req.Password) && (!string.IsNullOrWhiteSpace(req.Contact)))
            {

                string? token = await service.LogIn(req);

                if (string.IsNullOrWhiteSpace(token))
                {

                    return StatusCode(401, "Wrong contact, and/or password.");

                }

                return StatusCode(200, new { token });

            }

            return StatusCode(400, "Invalid contact, and/or password.");
        }

        [HttpGet ("RequestVerification")]
        [Authorize]
        public async Task<IActionResult> RequestVerification()
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid id);
            bool isVerified = User.Claims.FirstOrDefault(c => c.Type == "verified")?.Value?.Equals("true", StringComparison.OrdinalIgnoreCase) == true;

            if (validGuid && !isVerified)
            {
                await service.RequestAccountVerification(id);
                return StatusCode(202, "Your code will be sent shortly.");
            }

            return StatusCode(400,"There is an issue with your request.");
        }

        [HttpPost("Verify/{code}")]
        [Authorize]
        public async Task<IActionResult> Verify([FromRoute] int code)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid id);

            if (validGuid)
            {           

                await service.VerifyAccount(id, code);
                if (await service.CheckAccountVerification(id))
                {
                    return StatusCode(200, "Verified.");
                }

            }
            return StatusCode(401, "Verification failure.");
        }

        [HttpPost("SetRole/{id}/{role}")]
        [Authorize(Roles ="Owner")]
        public async Task<IActionResult> SetRole([FromRoute] Guid id, [FromRoute] Access role)
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid owner_id);

            if(validGuid && await service.CheckIsAuthorizedToModify(owner_id, id))
            {
                await service.SetRole(id, role);
                return StatusCode(200, "Updated Role.");
            }

            return StatusCode(403, "This action is not allowed.");

        }

        [HttpDelete("DeleteAccount")]
        [Authorize]
        public async Task<IActionResult> DeleteAccount()
        {
            bool validGuid = Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out Guid id);

            if (validGuid && !await service.CheckIsLastOwner(id))
            {
                await service.Delete(id);
                return StatusCode(204);
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
                await service.Delete(id);
                return StatusCode(204);
            }

            return StatusCode(401, "You are not authorized to ban this user.");
           
        }



    }

}
