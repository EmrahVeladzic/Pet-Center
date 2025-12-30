using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterModels.Requests;
using PetCenterServices.Utils;

namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ControllerTemplate<TEntity, TSearch,TRequest,TResponse, TService> : ControllerBase where TEntity : BaseTableEntity where TSearch : BaseSearchObject where TRequest : IBaseRequestDTO where TResponse : IBaseResponseDTO where TService : IBaseCRUDService<TEntity,TSearch,TRequest,TResponse>
    {
        protected readonly TService service;

        public ControllerTemplate(TService s)
        {
            service = s;
        }

        [Authorize]
        [HttpGet]
        public virtual async Task<IActionResult>Get([FromQuery] TSearch search)
        {           
            return ResultConverter.Convert<List<TResponse>>(await service.Get(search));
        }

        [Authorize]
        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById([FromRoute]Guid id)
        {            
            return StatusCode(200, await service.GetById(id));
        }


        [Authorize]
        [HttpPost]
        public virtual async Task<IActionResult> Post([FromBody] TRequest ent)
        {
            await service.Post(ent);
            return StatusCode(201);
        }


        [Authorize]
        [HttpPut]
        public virtual async Task<IActionResult> Put([FromBody] TRequest ent)
        {
            await service.Put(ent);
            return StatusCode(200);
        }


        [Authorize]
        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete([FromRoute]Guid id)
        {
            await service.Delete(id);
            return StatusCode(204);
        }


    }

    public static class ResultConverter
{
    public static IActionResult Convert<T>(ServiceOutput<T> output)
    {
        if (output.Code == HttpCode.NoContent)
        {
            return new Microsoft.AspNetCore.Mvc.NoContentResult(); 
        }
       
        if ((int)output.Code >= 400)
        {
            return new ObjectResult(new { error = output.ErrorMessage }) 
            { 
                StatusCode = (int)output.Code 
            };
        }

        return new ObjectResult(output.Body) 
        { 
            StatusCode = (int)output.Code 
        };
    }
}

}
