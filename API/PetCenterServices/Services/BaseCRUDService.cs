using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.SearchObjects;
using PetCenterServices.Interfaces;
using PetCenterServices.Utils;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace PetCenterServices.Services
{
    public class BaseCRUDService<TEntity,TSearch,TRequest,TResponse> : IBaseCRUDService<TEntity,TSearch,TRequest,TResponse> where TEntity:BaseTableEntity where TSearch: BaseSearchObject where TRequest: IBaseRequestDTO where TResponse : IBaseResponseDTO<TEntity,TResponse>
    {
        protected PetCenterDBContext dbContext;
        protected DbSet<TEntity> dbSet;

        public BaseCRUDService(PetCenterDBContext ctx)
        {
            dbContext = ctx;
            dbSet = dbContext.Set<TEntity>();
        }

        protected virtual  Task<IQueryable<TEntity>> Filter(Guid token_holder, TSearch search)
        {           
            return Task.FromResult<IQueryable<TEntity>>(dbSet.OrderBy(o=>o.Id));
        }

        protected int GetPageCount(int count, int PageSize)
        {
            return Math.Max((int)Math.Ceiling((double)count / PageSize),1);
        }

        public virtual async Task<ServiceOutput<int>> Count(Guid token_holder, TSearch search)
        {       
            IQueryable<TEntity> entities = await Filter(token_holder,search);   
            return ServiceOutput<int>.Success(GetPageCount(await entities.CountAsync(),search.PageSize));
        }


        public virtual async Task<ServiceOutput<List<TResponse>>> Get(Guid token_holder, TSearch search)
        {
            IQueryable<TEntity> query = await Filter(token_holder,search);
            List<TEntity> entities = await query.Skip(search.Page*search.PageSize).Take(search.PageSize).ToListAsync();
            return  ServiceOutput<List<TResponse>>.Success(entities.Select(e=>TResponse.FromEntity(e)!).ToList());
        }

        public virtual async Task<ServiceOutput<TResponse>> GetById(Guid token_holder,Guid id, Access authorization_level)
        {
            TEntity? entity = await dbSet.FindAsync(id);

            if (entity != null) 
            {      
                return  ServiceOutput<TResponse>.Success(TResponse.FromEntity(entity));                  
            }
            
            return ServiceOutput<TResponse>.Error(HttpCode.NotFound, "No resource with this ID exists.");
            
        }

        public virtual async Task<ServiceOutput<TResponse>> Post(Guid token_holder,TRequest req)
        {
            bool valid = req.Validate();
            if (!valid)
            {
                return ServiceOutput<TResponse>.Error(HttpCode.BadRequest,"Invalid request.");
            }

            if(req is ISerializableRequestDTO<TEntity> serializable)
            {
                TEntity? ent = serializable.ToEntity();

                if(ent!=null){

                    using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                    {
                        try
                        {
                            await dbSet.AddAsync(ent);
                            await dbContext.SaveChangesAsync();
                            await tx.CommitAsync();
                            return ServiceOutput<TResponse>.Success(TResponse.FromEntity(ent),HttpCode.Created);
                        }
                        catch
                        {
                            await tx.RollbackAsync();
                        }
                    }

                   
                }     

            }
           
            return ServiceOutput<TResponse>.Error(HttpCode.InternalError, "Internal server error.");

        }

        public virtual async Task<ServiceOutput<TResponse>> Put(Guid token_holder,TRequest req)
        {      

            TEntity? ent = await dbSet.FindAsync(req.Id);

            if (ent != null)
            {

                if(req is ISerializableRequestDTO<TEntity> serializable)                
                {
                    TEntity? overwrite = serializable.ToEntity();
                    
                    if (overwrite != null)
                    {
                        

                        using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                        {
                            try
                            {
                                overwrite.Id=ent.Id;
                                dbSet.Entry(ent).CurrentValues.SetValues(overwrite);
                                await dbContext.SaveChangesAsync();
                                await tx.CommitAsync();
                                return ServiceOutput<TResponse>.Success(TResponse.FromEntity(ent));
                               
                            }
                            catch
                            {
                                await tx.RollbackAsync();
                            }
                        }



                    }
                    

                }
               
                return ServiceOutput<TResponse>.Error(HttpCode.InternalError, "Internal server error.");

            }

            return ServiceOutput<TResponse>.Error(HttpCode.NotFound,"No resource with this ID exists.");
        }

        public virtual async Task <ServiceOutput<object>> Delete(Guid token_holder,Guid id)
        {
            TEntity? current = await dbSet.FindAsync(id);
            if (current != null)
            {

                using (IDbContextTransaction tx = await dbContext.Database.BeginTransactionAsync())
                {
                    try
                    {
                        await current.StageDeletion<TEntity>(dbContext,dbSet);
                        await dbContext.SaveChangesAsync();                
                        await tx.CommitAsync();
                    }
                    catch
                    {
                        await tx.RollbackAsync();
                        return ServiceOutput<object>.Error(HttpCode.InternalError, "Internal server error.");

                    }
                }

               
            }

            return ServiceOutput<object>.Success(default,HttpCode.NoContent);
        }

        public virtual Task<ServiceOutput<object>> IsClearedToCreate(Guid token_holder, TRequest resource)
        {
            return Task.FromResult(ServiceOutput<object>.Error(HttpCode.NotImplemented,"Invalid action."));
        }

        public virtual Task<ServiceOutput<object>> IsClearedToUpdate(Guid token_holder, TRequest resource)
        {
            return Task.FromResult(ServiceOutput<object>.Error(HttpCode.NotImplemented,"Invalid action."));
        }

        public virtual Task<ServiceOutput<object>> IsClearedToDelete(Guid token_holder, Guid resourceId)
        {
            return Task.FromResult(ServiceOutput<object>.Error(HttpCode.NotImplemented,"Invalid action."));
        }
    }
}
