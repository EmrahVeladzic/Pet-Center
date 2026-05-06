using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using Microsoft.IdentityModel.JsonWebTokens;


namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerTemplate<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO,IAccountService>
    {

        public AccountController(IAccountService s):base(s) { }


        protected bool TryGetJTI(out Guid token_id){

            token_id = default;

            return Guid.TryParse(User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value,out token_id);

        }

        protected bool TryGetJWTExpiry(out DateTime exp){

            exp = default;

            string? value = User.FindFirst(JwtRegisteredClaimNames.Exp)?.Value;

            if (value == null || !long.TryParse(value, out long seconds)){
                return false;
            }

            exp = DateTimeOffset.FromUnixTimeSeconds(seconds).UtcDateTime;

            return true;
        }

        [HttpGet("Count")]
        [NonAction]
        public override Task<IActionResult> Count([FromQuery] AccountSearchObject search)
        {
            throw new NotImplementedException();
        }

        [HttpGet("Transfer/{old_code}/{new_code}")]
        public async Task<IActionResult> Transfer([FromRoute] int old_code, [FromRoute] int new_code)
        {
            if (TryGetUserId(out Guid id))
            {
                return ResultConverter.Convert<string>(await service.TransferAccount(id,old_code,new_code));
            }
            return StatusCode(401,"Invalid token.");
        }

        [HttpGet("RequestTransfer")]
        public async Task<IActionResult> RequestTransfer()
        {
            if (TryGetUserId(out Guid id))
            {
                return ResultConverter.Convert<string>(await service.RequestAccountTransfer(id,null));
            }
            return StatusCode(401,"Invalid token.");
        }

        [HttpGet]
        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult>Get([FromQuery] AccountSearchObject search)
        {           
            return await base.Get(search);
        }
       
        [HttpPost]
        [AllowAnonymous]
        public override async Task<IActionResult> Post([FromBody] AccountRequestDTO req)
        {
            req.Contact=req.Contact.ToLowerInvariant();
            
            ServiceOutput<object> cleared = await service.IsClearedToCreate(Guid.Empty,req);

            if (!ServiceOutput<object>.IsSuccess(cleared))
            {
                return ResultConverter.Convert<object>(cleared);
            }

            return ResultConverter.Convert<AccountResponseDTO>(await service.Post(Guid.Empty,req));
            
        }


        [HttpPost("LogIn")]
        [AllowAnonymous]
        public async Task<IActionResult> LogIn([FromBody] AccountRequestDTO req)
        {
            req.Contact=req.Contact.ToLowerInvariant();
            return ResultConverter.Convert<string>(await service.LogIn(req));
        }


        [HttpPut("{id}")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] AccountRequestDTO req)
        {
            req.Contact = req.Contact.ToLowerInvariant();
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

         
        [HttpGet ("ForgotPassword/{contact}")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword([FromRoute]string contact)
        {
            
            return ResultConverter.Convert<string>(await service.RequestSingleTimeEntryCode(contact.ToLowerInvariant()));
            
        }


        [HttpGet("LogOut")]
        public async Task<IActionResult> LogOut()
        {
            if(TryGetJTI(out Guid jti) && TryGetJWTExpiry(out DateTime exp))
            {
                return ResultConverter.Convert<object>(await service.LogOut(jti,exp));
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
