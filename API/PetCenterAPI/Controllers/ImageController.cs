using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PetCenterAPI.Filters;
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

    
    public class ImageController : BLOBControllerTemplate<Image,ImageBLOB,ImageMetadata,ImageDTO,IImageService>
    {

        public ImageController(IImageService s):base(s) { }

        [RequireFileToken]
        [RequestSizeLimit((5 * 1024 * 1024))]
        public override Task<IActionResult> Post()
        {
            return base.Post();
        }
      

    }

}
