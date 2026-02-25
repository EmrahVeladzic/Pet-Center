using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace PetCenterAPI.Controllers
{
   
    [ApiController]
    [Route("/")]
    public class HealthController : ControllerBase
    {
        [AllowAnonymous]
        [HttpGet]
        public IActionResult Get() 
        {
            return StatusCode(200,"PetCenterAPI is running!");
        }
    }

}