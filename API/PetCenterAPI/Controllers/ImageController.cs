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
    public class ImageController : ControllerTemplate<Image,ImageSearchObject,ImageDTO,ImageDTO,IImageService>
    {

        public ImageController(IImageService s):base(s) { }

        [HttpGet]
        [Authorize(Roles ="Owner,Admin")]
        public override async Task<IActionResult> Get([FromQuery] ImageSearchObject search)
        {
            return await base.Get(search);
        }

        [NonAction]
        public override Task<IActionResult> GetById(Guid id)
        {
            throw new NotSupportedException();
        }

        [NonAction]
        public override Task<IActionResult> Put([FromRoute]Guid id,[FromBody]ImageDTO ent)
        {
            throw new NotSupportedException();
        }

        [HttpPost]
        public override async Task<IActionResult> Post([FromBody] ImageDTO ent)
        {
            if(TryGetUserId(out Guid user_id))
            {             

                return ResultConverter.Convert<ImageDTO>(await service.Post(user_id,ent));              
                
            }
            return StatusCode(401,"Invalid token.");           
        }
      

    }

}
