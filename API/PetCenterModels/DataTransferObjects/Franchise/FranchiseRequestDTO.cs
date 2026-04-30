using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;
using PetCenterModels.ModelUtils;

namespace PetCenterModels.DataTransferObjects
{
    public class FranchiseRequestDTO : IBaseRequestDTO
    {

        public Guid? CreationFormId { get; set; }
        public Guid? Id { get; set; }

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        [MaxLength(75)]        
        public string FranchiseName { get; set; } = string.Empty;
        [MaxLength(255)]
        public string Contact { get; set; } = string.Empty;

        public bool Validate()
        {
            Contact=Contact.ToLowerInvariant();
           
            return !string.IsNullOrWhiteSpace(FranchiseName) && ModelValidationUtils.ValidateContact(Contact);
        }
    }

}