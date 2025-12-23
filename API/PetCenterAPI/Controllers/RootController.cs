using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("/")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() 
    {
        return StatusCode(200,"PetCenterAPI is running!");
    }
}