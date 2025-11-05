using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;

namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ControllerTemplate<TEntity, TSearch> : ControllerBase where TEntity : BaseTableEntity where TSearch : BaseSearchObject
    {
        [Authorize]
        [HttpGet]
        public virtual async Task<IActionResult>Get([FromQuery] TSearch search)
        {
            await Task.CompletedTask;
            return StatusCode(200);
        }

        [Authorize]
        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById(int id)
        {
            await Task.CompletedTask;
            return StatusCode(200);
        }


        [Authorize]
        [HttpPost]
        public virtual async Task<IActionResult> Post([FromBody] TEntity ent)
        {
            await Task.CompletedTask;
            return StatusCode(201);
        }


        [Authorize]
        [HttpPut]
        public virtual async Task<IActionResult> Put([FromBody] TEntity ent)
        {
            await Task.CompletedTask;
            return StatusCode(200);
        }


        [Authorize]
        [HttpDelete]
        public virtual async Task<IActionResult> Delete(int id)
        {
            await Task.CompletedTask;
            return StatusCode(204);
        }

    }
}
