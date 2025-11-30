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
        public async Task<IActionResult> Register([FromBody] AccountRequestObject req)
        {
            if (!string.IsNullOrEmpty(req.Password) && (!string.IsNullOrEmpty(req.Contact))){

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
        public async Task<IActionResult> LogIn([FromBody] AccountRequestObject req)
        {
            if (!string.IsNullOrEmpty(req.Password) && (!string.IsNullOrEmpty(req.Contact)))
            {

                string? token = await service.LogIn(req);

                if (string.IsNullOrEmpty(token))
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
            int.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out int id);
            bool isVerified = User.Claims.FirstOrDefault(c => c.Type == "verified")?.Value?.Equals("true", StringComparison.OrdinalIgnoreCase) == true;

            if (id > 0 && !isVerified)
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
            int.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out int id);

            if (id>0)
            {           

                await service.VerifyAccount(id, code);
                if (await service.CheckAccountVerification(id))
                {
                    return StatusCode(200, "Verified.");
                }

            }
            return StatusCode(401, "Verification failure.");
        }

        [HttpDelete("DeleteAccount")]
        [Authorize]
        public async Task<IActionResult> DeleteAccount()
        {
            int.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out int id);

            if (! await service.CheckIsLastOwner(id))
            {
                await service.Delete(id);
                return StatusCode(204);
            }

            return StatusCode(403, "This action is not allowed.");
            
        }


        [HttpDelete("Ban/{id}")]
        [Authorize (Roles ="Owner,Admin")]
        public async Task<IActionResult> Ban([FromRoute] int id)
        {
            int.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value, out int admin_id);

            if (await service.CheckIsAuthorizedToBan(admin_id,id))
            {
                await service.Delete(id);
                return StatusCode(204);
            }

            return StatusCode(401, "You are not authorized to ban this user.");
           
        }

    }

}
