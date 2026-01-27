using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    public class AlbumIncludingTableEntity : BaseTableEntity
    {
        [Column("AlbumID")]
        public Guid AlbumId { get; set; }

        [ForeignKey(nameof(AlbumId))]
        public Album? Album { get; set; }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Albums.FindAsync(AlbumId) is Album album){await album.StageDeletion<Album>(ctx, ctx.Albums);}
            await base.StageDeletion<T>(ctx, set);
        }

    }
}
