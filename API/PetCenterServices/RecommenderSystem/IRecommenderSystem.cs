using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Linq.Expressions;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterServices.Recommender
{

    public interface IRecommenderSystem
    {
       
        public Task<IQueryable<Breed>> GetMostCompatibleBreeds(PetCenterDBContext ctx, IQueryable<Breed> filter, User user);
        public Task RecommendListingToUsers(PetCenterDBContext ctx, Listing listing);
        public Task<List<NoteSubDTO>> AddNotesToPet(PetCenterDBContext ctx, Individual pet);
        public Task<NoteSubDTO> AddUsageInfoToProductListing(PetCenterDBContext ctx, ProductListing listing,int usage, int supplies);
        public Task<NoteSubDTO> ShoppingList(PetCenterDBContext ctx, Guid UserId);

    }


}