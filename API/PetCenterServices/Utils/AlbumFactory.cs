using System;                   
using System.Threading.Tasks;    
using Microsoft.EntityFrameworkCore; 
using PetCenterModels;
using PetCenterModels.DBTables;
using PetCenterServices;

public static class AlbumFactory
{    

    public static async Task<Guid> GenerateAlbum(PetCenterDBContext ctx, byte capacity)
    {
        
        Album album = new()
        {            
            Capacity = capacity,
            Reserved = 0
        };

        await ctx.Albums.AddAsync(album);
        await ctx.SaveChangesAsync();

        return album.Id;
    }

}