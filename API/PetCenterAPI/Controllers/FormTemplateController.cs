using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using PetCenterAPI;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FormTemplateController : ControllerTemplate<FormTemplate,FormTemplateSearchObject,FormTemplateDTO,FormTemplateDTO,IFormTemplateService>
    {

        public FormTemplateController(IFormTemplateService s):base(s) { }

        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("{id}")]
        public override Task<IActionResult> Put([FromRoute] Guid id, [FromBody] FormTemplateDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return base.Put(id, ent, user_id, session);
        }
        [Authorize(Roles = "Admin,Owner")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(Guid id, [UserId] Guid user_id)
        {
            return base.Delete(id, user_id);
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpPost]
        public override Task<IActionResult> Post([FromBody] FormTemplateDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return base.Post(ent, user_id, session);
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("Field")]
        public async Task<IActionResult> SetField([FromBody]FormTemplateFieldDTO field)
        {
            return ResultConverter.Convert<FormTemplateFieldDTO>(await service.SetField(field));
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpDelete("Field/{id}")]
        public async Task<IActionResult> DeleteField([FromRoute]Guid id)
        {
            return ResultConverter.Convert<object>(await service.DeleteField(id));
        }
    }

}