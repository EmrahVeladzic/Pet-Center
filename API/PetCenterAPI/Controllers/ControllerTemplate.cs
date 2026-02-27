using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterModels.DataTransferObjects;
using PetCenterServices.Utils;
using System.Security.Claims;

namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ControllerTemplate<TEntity, TSearch,TRequest,TResponse, TService> : ControllerBase where TEntity : BaseTableEntity where TSearch : BaseSearchObject where TRequest : IBaseRequestDTO where TResponse : IBaseResponseDTO<TEntity,TResponse> where TService : IBaseCRUDService<TEntity,TSearch,TRequest,TResponse>
    {
        protected readonly TService service;

        protected bool TryGetUserId(out Guid user_id){

            user_id = default;

            return Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value,out user_id);

        }

        protected Access SpecifySearchAuthority()
        {
            if (User.IsInRole("Admin")||User.IsInRole("Owner"))
            {
                return Access.Admin;
            }
            else if (User.IsInRole("Employee"))
            {
                return Access.BusinessAccount;
            }
            else
            {
                return Access.User;
            }
        }

        public ControllerTemplate(TService s)
        {
            service = s;
        }

       
        [HttpGet]
        public virtual async Task<IActionResult>Get([FromQuery] TSearch search)
        {  
            if (TryGetUserId(out Guid id))
            {
                search.AuthoritySpecifier = SpecifySearchAuthority();
                return ResultConverter.Convert<List<TResponse>>(await service.Get(id,search));
            }
            return StatusCode(401,"Invalid token.");         
            
        }

  
        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById([FromRoute]Guid id)
        {     
            
            if (TryGetUserId(out Guid usr_id))
            {
                return ResultConverter.Convert<TResponse>(await service.GetById(usr_id,id,SpecifySearchAuthority()));
            }
            return StatusCode(401,"Invalid token.");          
            
        }


        [HttpGet("count")]
        public virtual async Task<IActionResult> Count([FromQuery] TSearch search)
        {

            if (TryGetUserId(out Guid id))
            {
                  return ResultConverter.Convert<int>(await service.Count(id,search));
            }
            return StatusCode(401,"Invalid token.");   
          
        }

    
        [HttpPost]
        public virtual async Task<IActionResult> Post([FromBody] TRequest ent)
        {
            if(TryGetUserId(out Guid user_id))
            {
                ServiceOutput<object> cleared = await service.IsClearedToCreate(user_id,ent);

                if (!ServiceOutput<object>.IsSuccess(cleared))
                {
                    return ResultConverter.Convert<object>(cleared);
                }

                return ResultConverter.Convert<TResponse>(await service.Post(user_id,ent));
                              
                
            }
            return StatusCode(401,"Invalid token.");           
        }
 
        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] TRequest ent)
        {
            if(TryGetUserId(out Guid user_id))
            {
                ent.Id = id;
                
                ServiceOutput<object> cleared = await service.IsClearedToUpdate(user_id,ent);

                if (!ServiceOutput<object>.IsSuccess(cleared))
                {
                    return ResultConverter.Convert<object>(cleared);
                }


                return ResultConverter.Convert<TResponse>(await service.Put(user_id,ent));
                              
                
            }
            return StatusCode(401,"Invalid token.");  

        }
  
        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete([FromRoute]Guid id)
        {
            if(TryGetUserId(out Guid user_id))
            {
               
                ServiceOutput<object> cleared = await service.IsClearedToDelete(user_id,id);

                if (!ServiceOutput<object>.IsSuccess(cleared))
                {
                    return ResultConverter.Convert<object>(cleared);
                }
               
                return ResultConverter.Convert<object>(await service.Delete(user_id,id));
                              
                
            }
            return StatusCode(401,"Invalid token."); 

        }


    }

    public static class ResultConverter
{
    public static IActionResult Convert<T>(ServiceOutput<T> output){
        if (output.Code == HttpCode.NoContent)
        {
            return new Microsoft.AspNetCore.Mvc.NoContentResult(); 
        }
       
        if (!ServiceOutput<T>.IsSuccess(output))
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
