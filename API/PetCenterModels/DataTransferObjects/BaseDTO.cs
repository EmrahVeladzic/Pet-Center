using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.Requests
{
    public interface IBaseRequestDTO
    {             
        public Guid? Id { get; set; }
        public bool Validate();
    }

    public interface ISerializableRequestDTO<TEntity> : IBaseRequestDTO where TEntity: BaseTableEntity
    {
        public TEntity? ToEntity();
    }

    public interface IBaseResponseDTO<TEntity,TSelf>  where TEntity :BaseTableEntity where TSelf: IBaseResponseDTO<TEntity,TSelf>
    {       
        public Guid? Id {get; set;}
        public static abstract TSelf? FromEntity(TEntity? entity);

    }
 
}
