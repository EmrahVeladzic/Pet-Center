using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System.Security.Claims;
using PetCenterModels.ModelUtils;


namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FormController : ControllerTemplate<Form,FormSearchObject,FormDTO,FormDTO,IFormService>
    {

        public FormController(IFormService s):base(s) { }

        [HttpPost]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Post([FromBody] FormDTO ent)
        {
            ent.DefaultContact= ent.DefaultContact.ToLowerInvariant();
            return await base.Post(ent);
        }
        
     
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById([FromRoute] Guid id)
        {
            if(TryGetUserId(out Guid user_id) && TryGetJTI(out Guid session))
            {
                return ResultConverter.Convert<FormDTO>(await service.GetById(session,user_id,id,SpecifySearchAuthority(),FileScope.Invalid));
            }
            return StatusCode(401,"Invalid token.");
        }



        [HttpPut("{id}")]
        [Authorize(Roles ="Employee")]
        public override async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] FormDTO ent)
        {
            ent.DefaultContact= ent.DefaultContact.ToLowerInvariant();
            return await base.Put(id, ent);
        }
        
        [Authorize(Roles = "Employee")]
        [HttpDelete("{id}")]
        public override Task<IActionResult> Delete(Guid id)
        {
            return base.Delete(id);
        }


        [Authorize(Roles = "Admin,Owner")]
        [HttpDelete("Deny/{id}")]
        public async Task<IActionResult> DenyForm ([FromRoute] Guid id, [FromQuery] string reason)
        {
            return ResultConverter.Convert<object>(await service.DenyForm(id,reason));
        }
    }

}
