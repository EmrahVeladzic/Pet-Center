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
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerTemplate<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO,IAccountService>
    {

        public AccountController(IAccountService s):base(s) { }

        [HttpGet]
        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult>Get([FromQuery] AccountSearchObject search)
        {           
            return ResultConverter.Convert<List<AccountResponseDTO>>(await service.Get(search));
        }

        [HttpPost]
        [AllowAnonymous]
        public override async Task<IActionResult> Post([FromBody] AccountRequestDTO req)
        {
            req.Contact=req.Contact?.ToLower();
            
            ServiceOutput<object> cleared = await service.IsClearedToCreate(null,req);

            if (!ServiceOutput<object>.IsSuccess(cleared))
            {
                return ResultConverter.Convert<object>(cleared);
            }

            return ResultConverter.Convert<AccountResponseDTO>(await service.Post(null,req));
            
        }


        [HttpPost("LogIn")]
        [AllowAnonymous]
        public async Task<IActionResult> LogIn([FromBody] AccountRequestDTO req)
        {
            return ResultConverter.Convert<string>(await service.LogIn(req));
        }


        [HttpPut("{id}")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] AccountRequestDTO req)
        {
            req.Contact = req.Contact?.ToLower();
            return await base.Put(id,req);
        }

       
        [HttpGet ("RequestVerification")]
        [AllowUnverified]
        public async Task<IActionResult> RequestVerification()
        {
            if (TryGetUserId(out Guid id))
            {
                return ResultConverter.Convert<string>(await service.RequestAccountVerification(id));
            }
            return StatusCode(401,"Invalid token.");
        }

        
        [HttpPost("Verify/{code}")]
        [AllowUnverified]
        public async Task<IActionResult> Verify([FromRoute] int code)
        {
            if (TryGetUserId(out Guid id))
            {           
                return ResultConverter.Convert<string>(await service.VerifyAccount(id,code));
            }
            return StatusCode(400,"Invalid token.");
        }

        [HttpPut("SetRole/{id}/{role}")]
        [Authorize(Roles ="Owner")]
        public async Task<IActionResult> SetRole([FromRoute] Guid id, [FromRoute] Access role)
        {

            if(TryGetUserId(out Guid owner_id))
            {
                return ResultConverter.Convert<string>(await service.SetRole(owner_id,id,role));
            }

            return StatusCode(401, "Invalid token.");

        }

   

    }

}
