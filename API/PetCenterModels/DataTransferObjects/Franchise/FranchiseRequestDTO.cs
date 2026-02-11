using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.DataTransferObjects
{
    public class FranchiseRequestDTO : IBaseRequestDTO
    {

        public Guid? CreationFormId { get; set; }
        public Guid? Id { get; set; }
        public string FranchiseName { get; set; } = string.Empty;
        public string Contact { get; set; } = string.Empty;

        public bool Validate()
        {
            EmailAddressAttribute e = new();
            return !string.IsNullOrWhiteSpace(FranchiseName) && e.IsValid(Contact);
        }
    }

}