using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LivingConditionFieldController : ControllerTemplate<LivingConditionField,LivingConditionSearchObject,LivingConditionFieldDTO,LivingConditionFieldDTO,ILivingConditionFieldService>
    {

        public LivingConditionFieldController(ILivingConditionFieldService s):base(s) { }

       

        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("{id}")]
        public override Task<IActionResult> Put([FromRoute] Guid id, [FromBody] LivingConditionFieldDTO ent)
        {
            return base.Put(id, ent);
        }
        
        [Authorize(Roles = "Admin,Owner")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(Guid id)
        {
            return base.Delete(id);
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpPost]
        public override Task<IActionResult> Post([FromBody] LivingConditionFieldDTO ent)
        {
            return base.Post(ent);
        }

        [Authorize(Roles ="User")]
        [HttpPut("Entry/{field_id}")]
        public async Task<IActionResult> TrackSupplies([FromRoute]Guid field_id, [FromQuery] bool answer)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<LivingConditionEntrySubDTO>(await service.AddEntry(user_id,field_id,answer));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="User")]
        [HttpDelete("Entry/{entry_id}")]
        public async Task<IActionResult> TrackSupplies([FromRoute]Guid entry_id)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<object>(await service.RemoveEntry(user_id,entry_id));
            }
            return StatusCode(401,"Invalid token.");
        }

    }

}
