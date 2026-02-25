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
    public class CategoryController : ControllerTemplate<Category,CategorySearchObject,CategoryDTO,CategoryDTO,ICategoryService>
    {

        public CategoryController(ICategoryService s):base(s) { }

        [NonAction]
        public override Task<IActionResult> GetById(Guid id)
        {
            throw new NotImplementedException();
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("{id}")]
        public override Task<IActionResult> Put([FromRoute] Guid id, [FromBody] CategoryDTO ent)
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
        public override Task<IActionResult> Post([FromBody] CategoryDTO ent)
        {
            return base.Post(ent);
        }

        [Authorize(Roles ="Admin,Owner")]
        [HttpPut("Usage/{consumable_id}/{kind_id}")]
        public async Task<IActionResult> TrackSupplies([FromRoute]Guid consumable_id, [FromRoute]Guid kind_id,[FromQuery] AnimalScale? scale,[FromQuery]int mass_grams=0)
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
        public async Task<IActionResult> TrackSupplies([FromRoute]Guid consumable_id, [FromRoute]Guid kind_id,[FromQuery]int mass_grams=0)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<SuppliesSubDTO>(await service.TrackSupplies(user_id,consumable_id,kind_id,mass_grams));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="User")]
        [HttpDelete("Supplies/{entry_id}")]
        public async Task<IActionResult> StopTrackingSupplyRecord([FromRoute]Guid entry_id)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<object>(await service.StopTracking(user_id,entry_id));
            }
            return StatusCode(401,"Invalid token.");
        }

    }

}
