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
    public class ProcedureController : ControllerTemplate<Procedure,ProcedureSearchObject,ProcedureDTO,ProcedureDTO,IProcedureService>
    {

        public ProcedureController(IProcedureService s):base(s) { }


        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("{id}")]
        public override Task<IActionResult> Put([FromRoute] Guid id, [FromBody] ProcedureDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
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
        public override Task<IActionResult> Post([FromBody] ProcedureDTO ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            return base.Post(ent, user_id, session);
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpPut("Specification/{procedure_id}/{kind_id}")]
        public async Task<IActionResult> SetSpecification([FromRoute]Guid procedure_id,[FromRoute]Guid kind_id, [FromQuery] Guid? breed_id = null, [FromQuery] bool optional = false, [FromQuery] bool? sex = null,  [FromQuery] int? age = null, [FromQuery] short? interval = null)
        {
            return ResultConverter.Convert<ProcedureSpecificationSubDTO>(await service.SetSpecification(procedure_id,kind_id,breed_id,optional,sex,age,interval));
        }

        [Authorize(Roles = "Admin,Owner")]
        [HttpDelete("Specification/{id}")]
        public async Task<IActionResult> RemoveSpecification([FromRoute]Guid id)
        {
            return ResultConverter.Convert<object>(await service.RemoveSpecification(id));
        }
    }

}