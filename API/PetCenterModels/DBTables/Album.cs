using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    [Table("Album", Schema = "File")]
    public class Album : BaseTableEntity
    {
        [Column("Capacity")]
        public byte Capacity { get; set; }

        [Column("Reserved")]
        public byte Reserved { get; set; }

        [Column("OwnerID")]
        public Guid PosterID {get; set;}

        public Album()
        {
            Reserved=0;
        }
        public static byte MaxCapacity = 5;

        public Album(byte capacity = 1)
        {
            if(capacity>MaxCapacity){capacity=MaxCapacity;}
            Capacity = capacity;
            Reserved = 0;
        }

        public override async Task StageDeletion<T>(PetCenterDBContext ctx, DbSet<T> set)
        {
            if(await ctx.Images.Where(i=>i.AlbumId==Id).ToArrayAsync() is Image[] i){ctx.Images.RemoveRange(i);}
            Reserved = 0;
        }

    }
}
