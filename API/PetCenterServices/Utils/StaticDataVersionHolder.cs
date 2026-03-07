namespace PetCenterServices.Utils
{
    public class StaticDataDTO
    {
        public Guid KindVersion {get; set;} = StaticDataVersionHolder.KindVersion;

        public Guid BreedVersion {get; set;} = StaticDataVersionHolder.BreedVersion;

        public Guid CategoryVersion {get; set;} = StaticDataVersionHolder.CategoryVersion;

        public Guid ProductVersion {get; set;} = StaticDataVersionHolder.ProductVersion;

        public Guid UsageVersion {get; set;} = StaticDataVersionHolder.UsageVersion;

        public Guid AnnouncementVersion {get; set;} = StaticDataVersionHolder.AnnouncementVersion;
        
        public Guid FormTemplateVersion {get; set;} = StaticDataVersionHolder.FormTemplateVersion;

        public Guid LivingConditionVersion {get; set;} = StaticDataVersionHolder.LivingConditionVersion;

        public Guid ProcedureVersion {get; set;} = StaticDataVersionHolder.ProcedureVersion;

        public Guid SpecificationVersion {get; set;} = StaticDataVersionHolder.SpecificationVersion;

    }

    public static class StaticDataVersionHolder
    {
        
        public static Guid KindVersion {get; set;} = Guid.NewGuid();

        public static Guid BreedVersion {get; set;} = Guid.NewGuid();

        public static Guid CategoryVersion {get; set;} = Guid.NewGuid();

        public static Guid ProductVersion {get; set;} = Guid.NewGuid();

        public static Guid UsageVersion {get; set;} = Guid.NewGuid();

        public static Guid AnnouncementVersion {get; set;} = Guid.NewGuid();
        
        public static Guid FormTemplateVersion {get; set;} = Guid.NewGuid();

        public static Guid LivingConditionVersion {get; set;} = Guid.NewGuid();

        public static Guid ProcedureVersion {get; set;} = Guid.NewGuid();

        public static Guid SpecificationVersion {get; set;} = Guid.NewGuid();

    }

}