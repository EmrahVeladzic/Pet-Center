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

namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ControllerTemplate<TEntity, TSearch,TRequest,TResponse, TService> : ControllerBase where TEntity : BaseTableEntity where TSearch : BaseSearchObject where TRequest : IBaseRequestDTO where TResponse : IBaseResponseDTO<TEntity,TResponse> where TService : IBaseCRUDService<TEntity,TSearch,TRequest,TResponse>
    {
        protected readonly TService service;

        
        protected bool TryGetJTI(out Guid token_id){

            token_id = default;

            return Guid.TryParse(User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value,out token_id);

        }

        protected bool TryGetJWTExpiry(out DateTime exp){

            exp = default;

            string? value = User.FindFirst(JwtRegisteredClaimNames.Exp)?.Value;

            if (value == null || !long.TryParse(value, out long seconds)){
                return false;
            }

            exp = DateTimeOffset.FromUnixTimeSeconds(seconds).UtcDateTime;

            return true;
        }

        protected bool TryGetUserId(out Guid user_id){

            user_id = default;

            return Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value,out user_id);

        }

        protected bool TryParseFileToken(out Guid user_id, out Guid album_id, out string file_hash, out string purpose, out PetCenterModels.ModelUtils.FileScope scope)
        {
            user_id = Guid.Empty;
            album_id = Guid.Empty;
            file_hash = string.Empty;
            purpose = string.Empty;
            scope = default;

            try
            {
                
                string? albumClaim = User.FindFirst("album_id")?.Value;
                string? hashClaim = User.FindFirst("file_hash")?.Value;
                string? purposeClaim = User.FindFirst("purpose")?.Value;
                string? scopeClaim = User.FindFirst("scope")?.Value;

                if(!TryGetUserId(out user_id))
                {
                    return false;
                }

                if (!Guid.TryParse(albumClaim, out album_id)){
                    return false;
                }

                if (hashClaim==null){
                    return false;
                }

                file_hash = hashClaim;

                if (string.IsNullOrWhiteSpace(purposeClaim)){
                    return false;
                }

                purpose = purposeClaim;

                PetCenterModels.ModelUtils.FileScope? parsedScope = Crypto.ValidateScope(scopeClaim ?? "");
                if (parsedScope == null){
                    return false;
                }

                scope = parsedScope.Value;

                if(scope==FileScope.ReadOnly && string.IsNullOrWhiteSpace(file_hash))
                {
                    return false;
                }

                return true;
            }
            catch
            {
                return false;
            }
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

  

        [HttpGet("Count")]
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

   

}
