using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.ModelUtils;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    public interface IMetadataOutput
    {
        
    }

    public interface IBaseBlobEntity<TMeta,TSelf> where TMeta : IMetadataOutput, new() where TSelf : IBaseBlobEntity<TMeta,TSelf>
    {
        public static abstract TSelf? TryCreateFromOctet(byte[] input, out TMeta metadata);
       
    }

    public class BaseBLOBEntity<TMeta> : IBaseBlobEntity<TMeta,BaseBLOBEntity<TMeta>> where TMeta : IMetadataOutput, new()
    {
        [Key]
        [Column("ID")]
        public String Id { get; set; } = string.Empty;

        [Column("BinaryData")]
        public byte[] Data {get; set;} = [];

        public TMeta CreateMeta()
        {
            return new();
        }

        public static BaseBLOBEntity<TMeta>? TryCreateFromOctet(byte[] input, out TMeta metadata) 
        {
            metadata = new();
            return null;
        }

    }
}

