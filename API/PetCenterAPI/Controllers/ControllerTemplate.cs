using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;

namespace PetCenterAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ControllerTemplate<TEntity, TSearch> : ControllerBase where TEntity : BaseTableEntity where TSearch : BaseSearchObject
    {
        private IBaseCRUDService<TEntity,TSearch> service;

        public ControllerTemplate(IBaseCRUDService<TEntity,TSearch> s)
        {
            service = s;
        }

        [Authorize]
        [HttpGet]
        public virtual async Task<IActionResult>Get([FromQuery] TSearch search)
        {           
            return StatusCode(200, await service.Get(search));
        }

        [Authorize]
        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById(int id)
        {            
            return StatusCode(200, await service.GetById(id));
        }


        [Authorize]
        [HttpPost]
        public virtual async Task<IActionResult> Post([FromBody] TEntity ent)
        {
            await service.Post(ent);
            return StatusCode(201);
        }


        [Authorize]
        [HttpPut]
        public virtual async Task<IActionResult> Put([FromBody] TEntity ent)
        {
            await service.Put(ent);
            return StatusCode(200);
        }


        [Authorize]
        [HttpDelete]
        public virtual async Task<IActionResult> Delete(int id)
        {
            await service.Delete(id);
            return StatusCode(204);
        }

    }
}
