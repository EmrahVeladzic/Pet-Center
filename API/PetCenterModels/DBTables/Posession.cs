using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PetCenterServices;

namespace PetCenterModels.DBTables
{
    [Table("Posession", Schema="Animal")]
    public class Posession : BaseTableEntity
    {
        [Column("OwnerID")]
        public Guid? OwnerId {get;set;}

        [Column("ShelterID")]
        public Guid? ShelterId {get;set;}

        public bool Owned {get;set;}


    }
    
}
