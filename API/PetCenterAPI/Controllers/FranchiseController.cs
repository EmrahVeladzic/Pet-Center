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
    public class FranchiseController : ControllerTemplate<Franchise,FranchiseSearchObject,FranchiseRequestDTO,FranchiseResponseDTO,IFranchiseService>
    {

        public FranchiseController(IFranchiseService s):base(s) { }


        [HttpPost]
        [Authorize(Roles = "Owner,Admin")]
        public override async Task<IActionResult> Post([FromBody] FranchiseRequestDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            ent.Contact = ent.Contact.ToLowerInvariant();

            return ResultConverter.Convert<FranchiseResponseDTO>(await service.Post(Guid.Empty,user_id,ent));

        }

        [HttpPut("{id}")]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] FranchiseRequestDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            ent.Contact= ent.Contact.ToLowerInvariant();
            return await base.Put(id, ent, user_id, session);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles ="Employee")]
        public override Task<IActionResult> Delete([FromRoute] Guid id, [UserId] Guid user_id)
        {
            return base.Delete(id, user_id);
        }



    }

}