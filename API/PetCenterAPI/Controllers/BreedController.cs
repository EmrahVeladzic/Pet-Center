using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using PetCenterAPI;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BreedController : ControllerTemplate<Breed,BreedSearchObject,BreedDTO,BreedDTO,IBreedService>
    {
        public BreedController(IBreedService s):base(s) { }

        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] BreedDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return await base.Put(id, ent, user_id, session);
        }

        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Post([FromBody] BreedDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return await base.Post(ent, user_id, session);
        }

        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id, [UserId] Guid user_id)
        {
            return await base.Delete(id, user_id);
        }

    }

}