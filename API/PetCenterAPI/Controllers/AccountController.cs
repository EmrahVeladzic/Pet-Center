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

        [HttpPost("Verify/{code}")]
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

    }
}
