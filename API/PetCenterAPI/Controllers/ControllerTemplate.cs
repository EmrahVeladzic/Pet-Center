using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using PetCenterModels.DBTables;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterModels.DataTransferObjects;
using PetCenterServices.Utils;
using System.Security.Claims;
using PetCenterModels.ModelUtils;
using Microsoft.IdentityModel.JsonWebTokens;
using PetCenterAPI;

namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ControllerTemplate<TEntity, TSearch,TRequest,TResponse, TService> : ControllerBase where TEntity : BaseTableEntity where TSearch : BaseSearchObject where TRequest : IBaseRequestDTO where TResponse : IBaseResponseDTO<TEntity,TResponse> where TService : IBaseCRUDService<TEntity,TSearch,TRequest,TResponse>
    {
        protected readonly TService service;

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
        public virtual async Task<IActionResult>Get([FromQuery] TSearch search, [UserId] Guid id, [SessionId] Guid session)
        {  
            search.Session=session;
            search.AuthoritySpecifier = SpecifySearchAuthority();
            return ResultConverter.Convert<List<TResponse>>(await service.Get(id,search));
        }

  

        [HttpGet("Count")]
        public virtual async Task<IActionResult> Count([FromQuery] TSearch search, [UserId] Guid id, [SessionId] Guid session)
        {
            search.Session=session;
            search.AuthoritySpecifier = SpecifySearchAuthority();
            return ResultConverter.Convert<int>(await service.Count(id,search));
        }

    
        [HttpPost]
        public virtual async Task<IActionResult> Post([FromBody] TRequest ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            ServiceOutput<object> cleared = await service.IsClearedToCreate(user_id,ent);

            if (!ServiceOutput<object>.IsSuccess(cleared))
            {
                return ResultConverter.Convert<object>(cleared);
            }

            return ResultConverter.Convert<TResponse>(await service.Post(session,user_id,ent));
        }
 
        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Put([FromRoute] Guid id, [FromBody] TRequest ent, [UserId] Guid user_id, [SessionId] Guid session)
        {
            ent.Id = id;

            ServiceOutput<object> cleared = await service.IsClearedToUpdate(user_id,ent);

            if (!ServiceOutput<object>.IsSuccess(cleared))
            {
                return ResultConverter.Convert<object>(cleared);
            }

            return ResultConverter.Convert<TResponse>(await service.Put(session,user_id,ent));
        }
  
        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete([FromRoute]Guid id, [UserId] Guid user_id)
        {
            ServiceOutput<object> cleared = await service.IsClearedToDelete(user_id,id);

            if (!ServiceOutput<object>.IsSuccess(cleared))
            {
                return ResultConverter.Convert<object>(cleared);
            }

            return ResultConverter.Convert<object>(await service.Delete(user_id,id));
        }


    }

   

}