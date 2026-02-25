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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
        }


        public DbSet<Account> Accounts { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Image> Images { get; set; }
        public DbSet<Album> Albums { get; set; }
        public DbSet<Facility> Facilities { get; set; }
        public DbSet<Franchise> Franchises { get;set; }
        public DbSet<Listing> Listings { get; set; }
        public DbSet<Registration> Registrations { get; set; }
        public DbSet<Comment> Comments {get; set;}
        public DbSet<Kind> AnimalKinds {get; set;}
        public DbSet<Breed> AnimalBreeds {get;set;}
        public DbSet<Individual> IndividualAnimals {get;set;}
        public DbSet<Procedure> MedicalProcedures {get;set;}
        public DbSet<MedicalProcedureSpecification> MedicalProcedureSpecifications {get;set;}
        public DbSet<MedicalRecordEntry> MedicalRecordEntries {get;set;}
        public DbSet<FormTemplate> FormTemplates {get;set;}
        public DbSet<FormTemplateField> FormTemplateFields {get;set;}
        public DbSet<FormFieldEntry> FormFieldEntries {get;set;}
        public DbSet<Form> Forms {get;set;}
        public DbSet<Category> Categories { get; set; }
        public DbSet<Item> Items { get; set; }
        public DbSet<Wishlist> Wishlists {get;set;}
        public DbSet<Notification> Notifications {get;set;}
        public DbSet<Available> ListingAvailable { get; set; }
        public DbSet<Announcement> Announcements {get;set;}
        public DbSet<EmployeeRecord> EmployeeRecords {get;set;}
        public DbSet<Report> Reports {get;set;}
        public DbSet<ProductListing> ProductListings {get;set;}
        public DbSet<MedicalListing> MedicalListings {get;set;}
        public DbSet<AnimalListing> AnimalListings {get;set;}
        public DbSet<Usage> UsageEstimates {get;set;}
        public DbSet<Supplies> SupplyRecords {get;set;}
        public DbSet<Discount> Discounts {get;set;}
        public DbSet<LivingConditionField> LivingConditionFields {get;set;}
        public DbSet<LivingConditionEntry> LivingConditionEntries {get;set;}

    }
}
