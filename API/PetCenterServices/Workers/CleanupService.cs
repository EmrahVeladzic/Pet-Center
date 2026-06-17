using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;
using Microsoft.Extensions.Logging;

namespace PetCenterServices.Workers
{
    
    public sealed class CleanupService : BackgroundService
    {
        
        private readonly IServiceScopeFactory scope_factory;
        private readonly ILogger<CleanupService> logger; 
        public CleanupService(IServiceScopeFactory factory, ILogger<CleanupService> _logger)
        {
            scope_factory = factory;
            logger=_logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await Task.Delay(TimeSpan.FromMinutes(5),stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                

                await using(AsyncServiceScope scope = scope_factory.CreateAsyncScope())
                {
                    PetCenterDBContext dBContext = scope.ServiceProvider.GetRequiredService<PetCenterDBContext>();
                    
                   
                    await RunCleanup(dBContext,logger,stoppingToken);
                }

                
                await Task.Delay(TimeSpan.FromMinutes(15),stoppingToken);
            }

        }


        private async Task<bool> CleanupBLOB<TBLOB,TEntity,TMeta>(PetCenterDBContext dBContext,DbSet<TEntity> metaSet, DbSet<TBLOB> blobSet,CancellationToken stoppingToken) where TEntity : BLOBReferencingEntity<TMeta> where TBLOB :BaseBLOBEntity<TMeta> where TMeta : IMetadataOutput , new()
        {
            bool had_work = false;
            bool proceed = true;
            while(proceed && !stoppingToken.IsCancellationRequested)
            {
                await using (IDbContextTransaction tx = await dBContext.Database.BeginTransactionAsync(stoppingToken))
                {
                    try
                    {
                        TBLOB[] orphaned = await blobSet.Where(b => !metaSet.Select(e => e.BLOBId).Contains(b.Id)).OrderBy(e=>e.Id).Take(50).ToArrayAsync(stoppingToken);
                        proceed = orphaned.Length>0;
                        if (orphaned.Length > 0)
                        {
                            had_work = true;
                        }
                        blobSet.RemoveRange(orphaned);
                        
                        await dBContext.SaveChangesAsync(stoppingToken);
                        await tx.CommitAsync(stoppingToken);
                    }
                    catch
                    {
                        await tx.RollbackAsync(stoppingToken);
                        throw;
                    }
                }                    
            }
            return had_work;
        }


        private async Task<bool> CleanupEntity<TEntity>(PetCenterDBContext dBContext,DbSet<TEntity> set,CancellationToken stoppingToken) where TEntity : ExpirableTableEntity
        {
            bool had_work = false;
            bool proceed = true;
            while(proceed && !stoppingToken.IsCancellationRequested)
            {
                await using (IDbContextTransaction tx = await dBContext.Database.BeginTransactionAsync(stoppingToken))
                {
                    try
                    {
                        List<TEntity> expired = await set.Where(e=>e.Expiry<=DateTime.UtcNow).OrderBy(e=>e.Id).Take(50).ToListAsync(stoppingToken);
                        proceed = expired.Count>0;
                        if (expired.Count > 0)
                        {
                            had_work = true;
                        }
                        foreach(TEntity exp in expired)
                        {
                            await exp.StageDeletion<TEntity>(dBContext,set,stoppingToken);
                        }
                        await dBContext.SaveChangesAsync(stoppingToken);
                        await tx.CommitAsync(stoppingToken);
                    }
                    catch
                    {
                        await tx.RollbackAsync(stoppingToken);
                        throw;
                    }
                }                    
            }
            return had_work;
        }

        private async Task RunCleanup(PetCenterDBContext dBContext,ILogger logger, CancellationToken stoppingToken)
        {
            
            try
            {
                await CleanupEntity<Registration>(dBContext,dBContext.Registrations,stoppingToken);
                await CleanupEntity<Announcement>(dBContext,dBContext.Announcements,stoppingToken);
                await CleanupEntity<Notification>(dBContext,dBContext.Notifications,stoppingToken);
                await CleanupEntity<Report>(dBContext,dBContext.Reports,stoppingToken);
                await CleanupEntity<Discount>(dBContext,dBContext.Discounts,stoppingToken);
                await CleanupEntity<SingleTimeEntry>(dBContext,dBContext.SingleTimeEntries,stoppingToken);
                await CleanupEntity<InvalidatedToken>(dBContext,dBContext.InvalidatedTokens,stoppingToken);
                await CleanupEntity<ContactTransfer>(dBContext,dBContext.ContactTransfers,stoppingToken);

                await CleanupBLOB<ImageBLOB,Image,ImageMetadata>(dBContext,dBContext.Images,dBContext.ImageBLOBs,stoppingToken); 
            }
            catch (OperationCanceledException)
            {
                
                logger.LogInformation("Cleanup aborted due to host shutdown.");
                
                
            }
            catch (Exception ex)
            {
                
                logger.LogError(ex,"Cleanup exception.");
                 
            }

        }
    }








}