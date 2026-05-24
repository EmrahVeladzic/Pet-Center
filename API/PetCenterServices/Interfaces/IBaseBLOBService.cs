using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Utils;

namespace PetCenterServices.Interfaces
{
    public interface IBaseBLOBService<TEntity,TBLOB,TMeta,TDTO> where TEntity : BLOBReferencingEntity<TMeta>, new() where TBLOB : BaseBLOBEntity<TMeta> where TMeta : IMetadataOutput,new() where TDTO: IBLOBReferencingDTO<TEntity,TDTO,TMeta>
    {
        public Task<ServiceOutput<TDTO>> Upload(Guid session, Guid token_holder, Guid insert_album, byte[] data);

        public Task<ServiceOutput<byte[]>> Download(Guid token_holder, string hash);

        public Task<ServiceOutput<object>> Delete(Guid token_holder,string hash, Guid album_id);

    }
}
