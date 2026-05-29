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

        public byte[] CurrentVersion { get; set; }

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

        public byte[] CurrentVersion { get; set; }

        public static abstract TSelf? FromEntity(TEntity? entity);

    }
    
    public interface IBLOBReferencingDTO<TEntity,TSelf,TMeta> : IBaseResponseDTO<TEntity,TSelf> where TEntity: BLOBReferencingEntity<TMeta> where TSelf : IBaseResponseDTO<TEntity, TSelf> where TMeta : IMetadataOutput
    {
        public string? Token {get; set;}

        public string Hash {get; set;}

        public bool CanWrite {get; set;}

        public static abstract TSelf? FromEntity(TEntity? entity, String token);

    }
 

    public interface IAlbumCarryingDTO<TEntity,TSelf,TMedia,TBLOBRef,TMeta> : IBaseResponseDTO<TEntity,TSelf> where TEntity : AlbumIncludingTableEntity where TSelf : IBaseResponseDTO<TEntity,TSelf> where TBLOBRef : BLOBReferencingEntity<TMeta>  where TMedia : IBLOBReferencingDTO<TBLOBRef,TMedia,TMeta> where TMeta:IMetadataOutput
    {
        public List<TMedia> Media { get; set; }

        public Guid? AlbumId {get; set;}

        public bool Locked {get; set;}

        public bool Full {get; set;}

        public string? MediaCreationToken {get; set;}

        public static abstract new TSelf? FromEntity(TEntity? entity);

        public static abstract TSelf? FromEntity(TEntity? entity, String token);
    }

  
}
