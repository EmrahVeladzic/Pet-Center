using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PetCenterServices.Utils;

namespace PetCenterAPI.Controllers
{
   
    [ApiController]
    [Route("/")]
    public class RootController : ControllerBase
    {
        [AllowAnonymous]
        [HttpGet]
        public IActionResult Get() 
        {
            return StatusCode(200,"PetCenterAPI is running!");
        }

        [Authorize]
        [HttpGet("Static")]
        public IActionResult GetStaticDataVersions()
        {      
            return StatusCode(200,new StaticDataDTO());
        }
    }

}