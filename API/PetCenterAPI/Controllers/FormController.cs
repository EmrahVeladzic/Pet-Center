using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using PetCenterModels.ModelUtils;
using PetCenterAPI;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FormController : ControllerTemplate<Form,FormSearchObject,FormDTO,FormDTO,IFormService>
    {

        public FormController(IFormService s):base(s) { }

        [HttpGet]
        [Authorize(Roles ="Employee,Owner,Admin")]
        public override Task<IActionResult> Get([FromQuery] FormSearchObject search, [UserId] Guid id, [SessionId] Guid session)
        {
            return base.Get(search, id, session);
        }

        [HttpPost]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Post([FromBody] FormDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            ent.DefaultContact= ent.DefaultContact.ToLowerInvariant();
            return await base.Post(ent, user_id, session);
        }
        [HttpGet("{id}")]
        [Authorize(Roles ="Employee,Owner,Admin")]
        public async Task<IActionResult> GetById([FromRoute] Guid id, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return ResultConverter.Convert<FormDTO>(await service.GetById(session,user_id,id,SpecifySearchAuthority(),FileScope.Invalid));
        }



        [HttpPut("{id}")]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] FormDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            ent.DefaultContact= ent.DefaultContact.ToLowerInvariant();
            return await base.Put(id, ent, user_id, session);
        }
        [Authorize(Roles = "Employee,Owner")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(Guid id, [UserId] Guid user_id)
        {
            return base.Delete(id, user_id);
        }


        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("Deny/{id}")]
        public async Task<IActionResult> DenyForm ([FromRoute] Guid id, [FromBody] TextPayloadDTO reason, [UserId] Guid user_id)
        {
            if (string.IsNullOrWhiteSpace(reason.Text) || reason.Text.Length > 150)
            {
                return ResultConverter.Fail(HttpCode.BadRequest,"You need to provide a reason, which is no longer than 150 characters.");
            }

            return ResultConverter.Convert<object>(await service.DenyForm(user_id,id,reason.Text));

        }
    }

}