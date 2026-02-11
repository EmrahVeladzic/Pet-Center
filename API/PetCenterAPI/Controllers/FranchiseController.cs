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
    public class FranchiseController : ControllerTemplate<Franchise,FranchiseSearchObject,FranchiseRequestDTO,FranchiseResponseDTO,IFranchiseService>
    {

        public FranchiseController(IFranchiseService s):base(s) { }


        [HttpPost]
        [Authorize(Roles = "Owner,Admin")]
        public override async Task<IActionResult> Post([FromBody] FranchiseRequestDTO ent)
        {
            return ResultConverter.Convert<FranchiseResponseDTO>(await service.Post(null,ent));
        }

        [HttpPut]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] FranchiseRequestDTO ent)
        {
            ent.Contact= ent.Contact.ToLower();
            return await base.Put(id, ent);
        }

        [HttpDelete]
        [Authorize(Roles ="Employee")]
        public override Task<IActionResult> Delete([FromRoute] Guid id)
        {
            return base.Delete(id);
        }

      


    }

}
