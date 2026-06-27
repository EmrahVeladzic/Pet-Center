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
using PetCenterAPI.Filters;


namespace PetCenterAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class BLOBControllerTemplate<TEntity,TBLOB,TMeta,TDTO,TService> : ControllerBase where TMeta:IMetadataOutput, new() where TEntity:BLOBReferencingEntity<TMeta> , new() where TBLOB:BaseBLOBEntity<TMeta> , new() where TDTO: IBLOBReferencingDTO<TEntity,TDTO,TMeta> where TService : IBaseBLOBService<TEntity,TBLOB,TMeta,TDTO>
    {
        protected readonly TService service;

        protected virtual long MaxUploadSize => 5 * 1024 * 1024;

        protected bool TryGetUserId(out Guid user_id){

            user_id = default;

            return Guid.TryParse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value,out user_id);

        }

        protected bool TryGetJTI(out Guid token_id){

            token_id = default;

            return Guid.TryParse(User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value,out token_id);

        }

    protected record FileTokenResult(
        Guid Session,
        Guid UserId,
        Guid AlbumId,
        string FileHash,
        string Purpose,
        PetCenterModels.ModelUtils.FileScope Scope,
        string Origin
    );

    protected async Task<FileTokenResult?> TryParseFileToken()
    {
        try
        {
            if (!TryGetUserId(out Guid user_id) || !TryGetJTI(out Guid session))
            {
                return null;
            }

            AuthenticateResult result = await HttpContext.AuthenticateAsync("FileToken");
            if (!result.Succeeded)
            {
                return null;
            }

            ClaimsPrincipal fileToken = result.Principal!;

            string? userClaim = fileToken.FindFirst("user_id")?.Value;
            string? albumClaim = fileToken.FindFirst("album_id")?.Value;
            string? hashClaim = fileToken.FindFirst("file_hash")?.Value;
            string? purposeClaim = fileToken.FindFirst("purpose")?.Value;
            string? scopeClaim = fileToken.FindFirst("scope")?.Value;
            string? sessionClaim = fileToken.FindFirst("session")?.Value;
            string? originClaim = fileToken.FindFirst("origin")?.Value;

            if (string.IsNullOrWhiteSpace(originClaim)) return null;
            if (user_id.ToString() != userClaim) return null;
            if (!Guid.TryParse(sessionClaim, out Guid claimGuid) || session != claimGuid) return null;
            if (!Guid.TryParse(albumClaim, out Guid album_id)) return null;
            if (hashClaim == null) return null;
            if (string.IsNullOrWhiteSpace(purposeClaim)) return null;

            PetCenterModels.ModelUtils.FileScope? parsedScope = Crypto.ValidateScope(scopeClaim ?? "");
            if (parsedScope == null) return null;

            if (parsedScope.Value == FileScope.ReadOnly && string.IsNullOrWhiteSpace(hashClaim)) return null;

            return new FileTokenResult(session, user_id, album_id, hashClaim, purposeClaim, parsedScope.Value, originClaim);
        }
        catch
        {
            return null;
        }
    }
            

        public BLOBControllerTemplate(TService s)
        {
            service = s;
        }

        [RequireFileToken]
        [HttpGet]
        public virtual async Task<IActionResult> Get()
        {
            FileTokenResult? ft = await TryParseFileToken();
            if(ft!=null)
            {
                if (ControllerContext.ActionDescriptor.ControllerName.ToLowerInvariant() == ft.Purpose.ToLowerInvariant() && ft.Scope!=FileScope.Invalid)
                {

                    ServiceOutput<object> cleared = await service.CheckScope(ft.UserId,ft.AlbumId,FileScope.ReadOnly,ft.Origin,ft.FileHash);

                    if (!ServiceOutput<object>.IsSuccess(cleared))
                    {
                        return ResultConverter.Convert<TDTO>(ServiceOutput<TDTO>.Error(cleared.Code,cleared.ErrorMessage!));
                    }

                    return ResultConverter.Convert<byte[]>(await service.Download(ft.UserId,ft.FileHash));
                }
            }

            return StatusCode(401,"Invalid token.");
        }

        [RequireFileToken]
        [HttpPost]
        public virtual async Task<IActionResult> Post()
        {
            FileTokenResult? ft = await TryParseFileToken();
            if(ft!=null)
            {

                if (ControllerContext.ActionDescriptor.ControllerName.ToLowerInvariant() == ft.Purpose.ToLowerInvariant() && ft.Scope == FileScope.Write)
                {

                    ServiceOutput<object> cleared = await service.CheckScope(ft.UserId,ft.AlbumId,FileScope.Write,ft.Origin,null);

                    if (!ServiceOutput<object>.IsSuccess(cleared))
                    {
                        return ResultConverter.Convert<TDTO>(ServiceOutput<TDTO>.Error(cleared.Code,cleared.ErrorMessage!));
                    }

                    if (Request.ContentLength is long declared && declared > MaxUploadSize)
                    {
                        return StatusCode(StatusCodes.Status413PayloadTooLarge, "File too large.");
                    }

                    using (MemoryStream ms = new MemoryStream())
                    {
                        byte[] buffer = new byte[81920];
                        long total = 0;
                        int read;
                        while ((read = await Request.Body.ReadAsync(buffer, 0, buffer.Length)) > 0)
                        {
                            total += read;
                            if (total > MaxUploadSize)
                            {

                                return StatusCode(StatusCodes.Status413PayloadTooLarge, "File too large.");
                            }
                            await ms.WriteAsync(buffer, 0, read);
                        }

                        byte[] data = ms.ToArray();
                        return ResultConverter.Convert<TDTO>(await service.Upload(ft.Session, ft.UserId, ft.AlbumId, data, ft.Origin));
                    }
        
                
                }
            }

            return StatusCode(401,"Invalid token.");
        }

        [RequireFileToken]
        [HttpDelete]
        public virtual async Task<IActionResult> Delete()
        {
            FileTokenResult? ft = await TryParseFileToken();
            if(ft!=null)
            {
                if (ControllerContext.ActionDescriptor.ControllerName.ToLowerInvariant() == ft.Purpose.ToLowerInvariant() && ft.Scope == FileScope.Write)
                {
                    ServiceOutput<object> cleared = await service.CheckScope(ft.UserId,ft.AlbumId,FileScope.Write,ft.Origin,ft.FileHash);

                    if (!ServiceOutput<object>.IsSuccess(cleared))
                    {
                        return ResultConverter.Convert<TDTO>(ServiceOutput<TDTO>.Error(cleared.Code,cleared.ErrorMessage!));
                    }

                    return ResultConverter.Convert<object>(await service.Delete(ft.UserId,ft.FileHash,ft.AlbumId));
                
                
                }
            }

            return StatusCode(401,"Invalid token.");
        }
       
    }

   

}
