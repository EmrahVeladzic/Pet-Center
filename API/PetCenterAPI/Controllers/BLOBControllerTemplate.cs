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
using Microsoft.AspNetCore.Authentication;
using System.IdentityModel.Tokens.Jwt;


namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class BLOBControllerTemplate<TEntity,TBLOB,TMeta,TDTO,TService> : ControllerBase where TMeta:IMetadataOutput, new() where TEntity:BLOBReferencingEntity<TMeta> , new() where TBLOB:BaseBLOBEntity<TMeta> , new() where TDTO: IBLOBReferencingDTO<TEntity,TDTO,TMeta> where TService : IBaseBLOBService<TEntity,TBLOB,TMeta,TDTO>
    {
        protected readonly TService service;

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
                if (!TryGetUserId(out user_id))
                {
                    return false;
                }

                string? rawToken = Request.Headers["X-File-Token"].FirstOrDefault();
                if (string.IsNullOrWhiteSpace(rawToken))
                {
                    return false;
                }

                JwtSecurityTokenHandler handler = new();
                JwtSecurityToken jwt = handler.ReadJwtToken(rawToken);

                string? albumClaim = jwt.Claims.FirstOrDefault(c => c.Type == "album_id")?.Value;
                string? hashClaim  = jwt.Claims.FirstOrDefault(c => c.Type == "file_hash")?.Value;
                string? purposeClaim = jwt.Claims.FirstOrDefault(c => c.Type == "purpose")?.Value;
                string? scopeClaim = jwt.Claims.FirstOrDefault(c => c.Type == "scope")?.Value;

                if (!Guid.TryParse(albumClaim, out album_id))
                {
                    return false;
                }

                if (hashClaim == null)
                {
                    return false;
                }

                file_hash = hashClaim;

                if (string.IsNullOrWhiteSpace(purposeClaim))
                {
                    return false;
                }

                purpose = purposeClaim;

                PetCenterModels.ModelUtils.FileScope? parsedScope = Crypto.ValidateScope(scopeClaim ?? "");
                if (parsedScope == null)
                {
                    return false;
                }

                scope = parsedScope.Value;

                if (scope == FileScope.ReadOnly && string.IsNullOrWhiteSpace(file_hash))
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
       
           

        public BLOBControllerTemplate(TService s)
        {
            service = s;
        }

        [HttpGet]
        public virtual async Task<IActionResult> Get()
        {
            if(TryParseFileToken(out Guid user_id, out Guid album_id, out string file_hash, out string purpose, out FileScope scope))
            {
                if (ControllerContext.ActionDescriptor.ControllerName.ToLowerInvariant() == purpose.ToLowerInvariant())
                {
                    return ResultConverter.Convert<byte[]>(await service.Download(user_id,file_hash));
                }
            }

            return StatusCode(401,"Invalid token.");
        }

        [HttpPost]
        public virtual async Task<IActionResult> Post()
        {
            if(TryParseFileToken(out Guid user_id, out Guid album_id, out string file_hash, out string purpose, out FileScope scope))
            {
                if (ControllerContext.ActionDescriptor.ControllerName.ToLowerInvariant() == purpose.ToLowerInvariant() && scope == FileScope.Write)
                {

                    using (MemoryStream ms = new MemoryStream()){

                        await Request.Body.CopyToAsync(ms);

                        byte[] data = ms.ToArray();

                        return ResultConverter.Convert<TDTO>(await service.Upload(user_id,album_id,data));
                    
                    }
                
                
                }
            }

            return StatusCode(401,"Invalid token.");
        }


        [HttpDelete]
        public virtual async Task<IActionResult> Delete()
        {
            if(TryParseFileToken(out Guid user_id, out Guid album_id, out string file_hash, out string purpose, out FileScope scope))
            {
                if (ControllerContext.ActionDescriptor.ControllerName.ToLowerInvariant() == purpose.ToLowerInvariant() && scope == FileScope.Write)
                {

                    return ResultConverter.Convert<object>(await service.Delete(user_id,file_hash,album_id));
                
                
                }
            }

            return StatusCode(401,"Invalid token.");
        }
       
    }

   

}
