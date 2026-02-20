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

    public class PetCenterVector5
    {

        public float Investment {get; set;} = 0.0f;
        public float Territory {get; set;} = 0.0f;
        public float Pricing {get; set;} = 0.0f;
        public float Longevity {get; set;} = 0.0f;
        public float Cohabitation {get; set;} = 0.0f;

        public PetCenterVector5(List<LivingConditionEntry> entries)
        {
            entries = entries.Where(e=>e.Field !=null).ToList();

            foreach(LivingConditionEntry entry in entries)
            {
                if (entry.Answer)
                {
                    Investment += entry.Field.InvestmentEffect;
                    Territory += entry.Field.TerritoryEffect;
                    Pricing += entry.Field.PricingEffect;
                    Longevity += entry.Field.LongevityEffect;
                    Cohabitation += entry.Field.CohabitationEffect;
                }
                else
                {
                    Investment -= entry.Field.InvestmentEffect;
                    Territory -= entry.Field.TerritoryEffect;
                    Pricing -= entry.Field.PricingEffect;
                    Longevity -= entry.Field.LongevityEffect;
                    Cohabitation -= entry.Field.CohabitationEffect;
                }
            }
        }
        
    }

    public interface IRecommenderSystem
    {
        public Expression<Func<Breed, float>> BuildDistanceExpression(PetCenterVector5 IdealVector);
        public Task<IQueryable<Breed>> GetMostCompatibleBreeds(PetCenterDBContext ctx, IQueryable<Breed> filter, User user);
        public Task RecommendListingToUsers(PetCenterDBContext ctx, Discount discount);
        public Task<List<NoteSubDTO>> AddNotesToPet(PetCenterDBContext ctx, Individual pet);
        public Task<NoteSubDTO> AddUsageInfoToProductListing(PetCenterDBContext ctx, ProductListing listing,int usage, int supplies);
        public Task<NoteSubDTO> ShoppingList(PetCenterDBContext ctx, Guid UserId);

    }


}