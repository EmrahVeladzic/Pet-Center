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
    public class BLOBReferencingEntity<TMeta> : BaseTableEntity where TMeta : IMetadataOutput
    {
        [Column("BLOBID")]
        public string BLOBId {get; set;} = string.Empty;

        [Column("OwningAlbumID")]        
        public Guid AlbumId { get; set; }

        [ForeignKey(nameof(AlbumId))]
        public Album OwningAlbum {get; set;} = null!;


        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set, CancellationToken cancel = default)
        {
            DBUtils.EnsureInTransaction(ctx);
            if(await ctx.Albums.FindAsync(AlbumId) is Album alb){alb.Capacity--;alb.Capacity=Math.Max(alb.Capacity,(byte)0);}
            await base.StageDeletion(ctx, set, cancel);
        }

        public virtual void LoadMetadata(TMeta metadata)
        {
            
        }
    }
}
