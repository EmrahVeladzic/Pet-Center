using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using PetCenterModels.DBTables;

namespace PetCenterServices.Workers
{
    
    public sealed class CleanupService : BackgroundService
    {
        
        private readonly IServiceScopeFactory scope_factory;
        public CleanupService(IServiceScopeFactory factory)
        {
            scope_factory = factory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await Task.Delay(TimeSpan.FromMinutes(5),stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                await using(AsyncServiceScope scope = scope_factory.CreateAsyncScope())
                {
                    PetCenterDBContext dBContext = scope.ServiceProvider.GetRequiredService<PetCenterDBContext>();
                    IHostEnvironment environment = scope.ServiceProvider.GetRequiredService<IHostEnvironment>();
                    await RunCleanup(dBContext,environment,stoppingToken);
                }

                
                await Task.Delay(TimeSpan.FromMinutes(15),stoppingToken);
            }

        }

        private async Task CleanupEntity<TEntity>(PetCenterDBContext dBContext,DbSet<TEntity> set,CancellationToken stoppingToken) where TEntity : ExpirableTableEntity
        {
            bool proceed = true;
            while(proceed && !stoppingToken.IsCancellationRequested)
            {
                await using (IDbContextTransaction tx = await dBContext.Database.BeginTransactionAsync(stoppingToken))
                {
                    try
                    {
                        List<TEntity> expired = await set.Where(e=>e.Expiry<DateTime.UtcNow).OrderBy(e=>e.Id).Take(50).ToListAsync(stoppingToken);
                        proceed = expired.Count>0;
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
            
        }

        private async Task RunCleanup(PetCenterDBContext dBContext,IHostEnvironment environment, CancellationToken stoppingToken)
        {
            
            try
            {
                await CleanupEntity<Registration>(dBContext,dBContext.Registrations,stoppingToken);
                await CleanupEntity<Announcement>(dBContext,dBContext.Announcements,stoppingToken);
                await CleanupEntity<Notification>(dBContext,dBContext.Notifications,stoppingToken);
                await CleanupEntity<Report>(dBContext,dBContext.Reports,stoppingToken);
                await CleanupEntity<Discount>(dBContext,dBContext.Discounts,stoppingToken);
                
            }
            catch (OperationCanceledException)
            {
                if (environment.IsDevelopment())
                {
                    Console.WriteLine("Cleanup aborted due to host shutdown.");
                }
            }
            catch (Exception ex)
            {
                if (environment.IsDevelopment())
                {
                    Console.WriteLine($"[ERROR] {ex.GetType().Name}: {ex.Message}");
                } 
            }

        }
    }








}