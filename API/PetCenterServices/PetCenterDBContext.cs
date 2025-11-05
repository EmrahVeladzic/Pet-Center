using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterModels.DBTables;

namespace PetCenterServices
{
    public class PetCenterDBContext : DbContext
    {

        public PetCenterDBContext()
        {
            
        }

        public PetCenterDBContext(DbContextOptions<PetCenterDBContext>options):base(options)
        {
            
        }


        public DbSet<Account> Accounts { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Image> Images { get; set; }
        public DbSet<Album> Albums { get; set; }
        public DbSet<Facility> Facilities { get; set; }
        public DbSet<Franchise> Franchises { get;set; }
        public DbSet<Listing> Listings { get; set; }

    }
}
