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
    public class CategoryController : ControllerTemplate<Category,CategorySearchObject,CategoryDTO,CategoryDTO,ICategoryService>
    {

        public CategoryController(ICategoryService s):base(s) { }


        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("{id}")]
        public override Task<IActionResult> Put([FromRoute] Guid id, [FromBody] CategoryDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
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
        public override Task<IActionResult> Post([FromBody] CategoryDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return base.Post(ent, user_id, session);
        }

        [Authorize(Roles ="Admin,Owner")]
        [HttpPut("Usage/{consumable_id}/{kind_id}")]
        public async Task<IActionResult> SetUsageEstimate([FromRoute]Guid consumable_id, [FromRoute]Guid kind_id,[FromQuery] AnimalScale? scale,[FromQuery]int mass_grams=0)
        {
            return ResultConverter.Convert<UsageSubDTO>(await service.SetUsageEstimate(consumable_id,kind_id,scale,mass_grams));   
        }

        [Authorize(Roles ="Admin,Owner")]
        [HttpDelete("Usage/{entry_id}")]
        public async Task<IActionResult> RemoveUsageEstimate([FromRoute]Guid entry_id)
        {            
            return ResultConverter.Convert<object>(await service.RemoveUsageEstimate(entry_id)); 
        }

        [Authorize(Roles ="User")]
        [HttpPut("Supplies/{consumable_id}/{kind_id}")]
        public async Task<IActionResult> TrackSupplies([FromRoute]Guid consumable_id, [FromRoute]Guid kind_id, [UserId] Guid user_id, [FromQuery]int mass_grams=0)
        {
            return ResultConverter.Convert<SuppliesSubDTO>(await service.TrackSupplies(user_id,consumable_id,kind_id,mass_grams));
        }

        [Authorize(Roles ="User")]
        [HttpDelete("Supplies/{entry_id}")]
        public async Task<IActionResult> StopTrackingSupplyRecord([FromRoute]Guid entry_id, [UserId] Guid user_id)
        {
            return ResultConverter.Convert<object>(await service.StopTracking(user_id,entry_id));
        }

    }

}