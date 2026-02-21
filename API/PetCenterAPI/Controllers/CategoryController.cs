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

    }

}
