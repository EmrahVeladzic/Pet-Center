using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using System.Reflection.Metadata.Ecma335;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IndividualController : ControllerTemplate<Individual,IndividualSearchObject,IndividualRequestDTO,IndividualResponseDTO,IIndividualService>
    {

        public IndividualController(IIndividualService s):base(s) { }

        [NonAction]
        public override Task<IActionResult> GetById(Guid id)
        {
            throw new NotImplementedException();
        }

        [Authorize(Roles ="Employee,User")]
        [HttpPost]
        public override async Task<IActionResult> Post([FromBody] IndividualRequestDTO ent)
        {
            return await base.Post(ent);
        }
        [Authorize(Roles ="Employee,User")]
        [HttpPut("{id}")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] IndividualRequestDTO ent)
        {
            return await base.Put(id, ent);
        }
        [Authorize(Roles ="Employee,User")]
        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            return await base.Delete(id);
        }

        [Authorize(Roles ="Employee,User")]
        [HttpPut("Medical/{animal_id}/{procedure_id}")]
        public async Task<IActionResult> SetMedicalRecord([FromRoute] Guid animal_id, [FromRoute] Guid procedure_id, [FromQuery] int? days_since)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<MedicalEntrySubDTO>(await service.SetMedicalRecord(user_id,animal_id,procedure_id,days_since));
            }
            return StatusCode(401,"Invalid token.");
        }

        [Authorize(Roles ="Employee,User")]
        [HttpPut("Copy/{animal_id}")]
        public async Task<IActionResult> CopyAnimal([FromRoute] Guid animal_id, [FromQuery] Guid? on_behalf)
        {
            if(TryGetUserId(out Guid user_id))
            {
                return ResultConverter.Convert<IndividualResponseDTO>(await service.CopyAnimal(user_id,animal_id,on_behalf,SpecifySearchAuthority()));
            }
            return StatusCode(401,"Invalid token.");
        }
    }

}
