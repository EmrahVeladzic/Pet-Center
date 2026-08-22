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
    public class LivingConditionFieldController : ControllerTemplate<LivingConditionField,LivingConditionSearchObject,LivingConditionFieldDTO,LivingConditionFieldDTO,ILivingConditionFieldService>
    {

        public LivingConditionFieldController(ILivingConditionFieldService s):base(s) { }


        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("{id}")]
        public override Task<IActionResult> Put([FromRoute] Guid id, [FromBody] LivingConditionFieldDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
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
        public override Task<IActionResult> Post([FromBody] LivingConditionFieldDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return base.Post(ent, user_id, session);
        }

        [Authorize(Roles ="User")]
        [HttpPut("Entry/{field_id}")]
        public async Task<IActionResult> AddEntry([FromRoute]Guid field_id, [FromQuery] bool answer, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<LivingConditionEntrySubDTO>(await service.AddEntry(user_id,field_id,answer));
        }

        [Authorize(Roles ="User")]
        [HttpDelete("Entry/{entry_id}")]
        public async Task<IActionResult> RemoveEntry([FromRoute]Guid entry_id, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<object>(await service.RemoveEntry(user_id,entry_id));
        }

    }

}