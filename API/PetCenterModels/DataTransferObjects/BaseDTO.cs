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
        public bool Validate();
    }

    public interface ISerializableRequestDTO<TEntity> : IBaseRequestDTO where TEntity: BaseTableEntity
    {
        public TEntity? ToEntity();
    }

    public interface IBaseResponseDTO 
    {       
        
    }
    public interface IDeserializableResponseDTO<TEntity> : IBaseResponseDTO where TEntity: BaseTableEntity
    {       
        public void FromEntity(TEntity? entity);
    }
}
