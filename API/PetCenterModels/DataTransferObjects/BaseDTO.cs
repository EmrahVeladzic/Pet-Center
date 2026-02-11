using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;

namespace PetCenterModels.DataTransferObjects
{
    public interface IGeneratedSubDTO
    {
        public string Title {get; set;}
        public string Body {get; set;}
    }

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
        public List<NoteSubDTO>? Notes {get; set;}

        public Guid? Id {get; set;}
        public static abstract TSelf? FromEntity(TEntity? entity);

    }
    
    public interface IAlbumCarryingDTO<TEntity,TSelf> : IBaseResponseDTO<TEntity,TSelf> where TEntity : AlbumIncludingTableEntity where TSelf : IBaseResponseDTO<TEntity,TSelf> 
    {
        public List<ImageDTO?>? Images { get; set; }

        public Guid AlbumId {get; set;}

        public new static abstract TSelf? FromEntity(TEntity? entity);
    }
 
}
