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
    public class FacilityController : ControllerTemplate<Facility,FacilitySearchObject,FacilityDTO,FacilityDTO,IFacilityService>
    {

        public FacilityController(IFacilityService s):base(s) { }

        [HttpPost]
        [Authorize(Roles = "Employee")]
        public override async Task<IActionResult> Post([FromBody] FacilityDTO ent)
        {
            ent.Contact = ent.Contact?.ToLowerInvariant();
            return ResultConverter.Convert<FacilityDTO>(await service.Post(Guid.Empty,ent));
        }

        [HttpPut("{id}")]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] FacilityDTO ent)
        {
            ent.Contact= ent.Contact?.ToLowerInvariant();
            return await base.Put(id, ent);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Employee")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            return await base.Delete(id);
        }

    }

}
