using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BreedController : ControllerTemplate<Breed,BreedSearchObject,BreedDTO,BreedDTO,IBreedService>
    {
        public BreedController(IBreedService s):base(s) { }
       
        [NonAction]
        public override Task<IActionResult> GetById(Guid id)
        {
            throw new NotImplementedException();
        }

        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] BreedDTO ent)
        {
            return await base.Put(id, ent);
        }

        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Post([FromBody] BreedDTO ent)
        {
            return await base.Post(ent);
        }

        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            return await base.Delete(id);
            
        }

    }

}
