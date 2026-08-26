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
using System.ComponentModel.DataAnnotations;
using PetCenterModels.ModelUtils;
using PetCenterAPI;


namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class AccountController : ControllerTemplate<Account,AccountSearchObject,AccountRequestDTO,AccountResponseDTO,IAccountService>
    {

        public AccountController(IAccountService s):base(s) { }


        [HttpPost("Transfer")]
        public async Task<IActionResult> Transfer([FromBody] TransferCodeDTO transfer, [UserId] Guid id)
        {
            return ResultConverter.Convert<string>(await service.TransferAccount(id,transfer.OldCode,transfer.NewCode));
        }

        [HttpPost("InitiateTransfer")]
        public async Task<IActionResult> InitiateTransfer([FromBody] TextPayloadDTO new_contact, [UserId] Guid id)
        {
            if (!ModelValidationUtils.ValidateContact(new_contact.Text))
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"Invalid contact.");
            }

            return ResultConverter.Convert<string>(await service.RequestAccountTransfer(id,new_contact.Text));
        }

        [HttpPost("RequestTransfer")]
        public async Task<IActionResult> RequestTransfer([UserId] Guid id)
        {
            return ResultConverter.Convert<string>(await service.RequestAccountTransfer(id,null));
        }

        [HttpGet]
        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult>Get([FromQuery] AccountSearchObject search, [UserId] Guid id, [SessionId] Guid session)
        {           
            search.Contact=search.Contact.ToLowerInvariant();
            return await base.Get(search,id,session);
        }

        [NonAction]
        public override async Task<IActionResult> Post([FromBody] AccountRequestDTO req, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return await base.Post(req,user_id,session);
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] AccountRequestDTO req)
        {
            req.Contact=req.Contact.ToLowerInvariant();
            
            ServiceOutput<object> cleared = await service.IsClearedToCreate(Guid.Empty,req);

            if (!ServiceOutput<object>.IsSuccess(cleared))
            {
                return ResultConverter.Convert<object>(cleared);
            }

            return ResultConverter.Convert<AccountResponseDTO>(await service.Post(Guid.Empty,Guid.Empty,req));
            
        }


        [HttpPost("LogIn")]
        [AllowAnonymous]
        public async Task<IActionResult> LogIn([FromBody] AccountRequestDTO req)
        {
            req.Contact=req.Contact.ToLowerInvariant();
            
            return ResultConverter.Convert<string>(await service.LogIn(req));
        }


        [NonAction]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] AccountRequestDTO req, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return await base.Put(id,req,user_id,session);
        }

       
        [HttpPost ("RequestVerification")]
        [AllowUnverified]
        public async Task<IActionResult> RequestVerification([UserId] Guid id)
        {
            return ResultConverter.Convert<string>(await service.RequestAccountVerification(id));
        }

         
        [HttpPost ("ForgotPassword")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword([FromBody]TextPayloadDTO contact)
        {
            if (!ModelValidationUtils.ValidateContact(contact.Text))
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"Invalid contact.");
            }
            
            return ResultConverter.Convert<string>(await service.RequestSingleTimeEntryCode(contact.Text.ToLowerInvariant()));
            
        }

        [HttpPost("Recover")]
        [AllowAnonymous]
        public async Task<IActionResult> RecoverAccount([FromBody] PasswordRecoveryDTO recovery)
        {
          
            if (string.IsNullOrWhiteSpace(recovery.NewPW)||recovery.NewPW.Length<4||recovery.NewPW.Length>255)
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"The new password should be between 4 and 255 characters long.");
            }

            recovery.Contact=recovery.Contact.ToLowerInvariant();

            if (!ModelValidationUtils.ValidateContact(recovery.Contact))
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"Please provide a valid contact.");
            }

            return ResultConverter.Convert<string>(await service.RecoverPassword(recovery));
         
        }

        [HttpPost("ChangePassword")]
        public async Task<IActionResult> ChangePassword([FromBody] PasswordChangeDTO change, [UserId] Guid id)
        {
            if (string.IsNullOrWhiteSpace(change.NewPW)||change.NewPW.Length<4||change.NewPW.Length>255)
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"The new password should be between 4 and 255 characters long.");
            }

            return ResultConverter.Convert<string>(await service.ChangePassword(id,change));
        }



        [HttpPost("LogOut")]
        public async Task<IActionResult> LogOut([SessionId] Guid jti, [SessionExpiry] DateTime exp)
        {
            return ResultConverter.Convert<object>(await service.LogOut(jti,exp));
        }
        
        [HttpPost("Verify")]
        [AllowUnverified]
        public async Task<IActionResult> Verify([FromBody] VerificationCodeDTO code, [UserId] Guid id, [SessionId] Guid session)
        {
            return ResultConverter.Convert<string>(await service.VerifyAccount(id,code.Code,session));
        }

        [HttpPut("SetRole/{id}/{role}")]
        [Authorize(Roles ="Owner")]
        public async Task<IActionResult> SetRole([FromRoute] Guid id, [FromRoute] Access role, [UserId] Guid owner_id)
        {
            return ResultConverter.Convert<string>(await service.SetRole(owner_id,id,role));
        }

   

    }

}