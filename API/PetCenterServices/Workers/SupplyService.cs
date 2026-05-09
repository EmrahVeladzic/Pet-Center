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
    
    public sealed class SupplyService : BackgroundService
    {
        
        private readonly IServiceScopeFactory scope_factory;

        private readonly ILogger<SupplyService> logger; 
        public SupplyService(IServiceScopeFactory factory, ILogger<SupplyService> _logger)
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
                    IHostEnvironment environment = scope.ServiceProvider.GetRequiredService<IHostEnvironment>();
                   
                    await RunRecalculation(dBContext,environment,logger,stoppingToken);
                }

                
                await Task.Delay(TimeSpan.FromMinutes(15),stoppingToken);
            }

        }

        private async Task RunRecalculation(PetCenterDBContext dBContext,IHostEnvironment environment,ILogger logger, CancellationToken stoppingToken)
        {
            
            try
            {              
                bool proceed = true;
                while(proceed && !stoppingToken.IsCancellationRequested)
                {
                    await using (IDbContextTransaction tx = await dBContext.Database.BeginTransactionAsync(stoppingToken))
                    {
                        try
                        {
                            List<Supplies> supplies = await dBContext.SupplyRecords.Include(s=>s.RelevantUser).ThenInclude(u=>u.OwnedAnimals).Where(s=>s.Evaluated<DateTime.UtcNow.AddDays(-1)).OrderBy(s=>s.Id).Take(50).ToListAsync(stoppingToken);
                            proceed = supplies.Count>0;

                            foreach(Supplies sup in supplies)
                            {
                                
                                sup.MassGrams-= await Utils.UserUtils.GetTotalDailyUsageForCategory(dBContext,sup.CategoryId,sup.KindId,sup.RelevantUser.OwnedAnimals,stoppingToken);
                                sup.MassGrams=Math.Max(sup.MassGrams,0);
                                sup.Evaluated=DateTime.UtcNow;
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
            catch (OperationCanceledException)
            {
                if (environment.IsDevelopment())
                {
                    logger.LogInformation("Supply update aborted due to host shutdown.");
                }
            }
            catch (Exception ex)
            {
                if (environment.IsDevelopment())
                {
                    logger.LogError(ex,"Supply worker exception.");
                } 
            }

        }
    }








}