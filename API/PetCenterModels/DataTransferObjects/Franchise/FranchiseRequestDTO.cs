using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;

namespace PetCenterModels.Requests
{
    public class FranchiseRequestDTO : IBaseRequestDTO
    {

        public Guid? CreationFormId { get; set; }
        public Guid? Id { get; set; }
        public string FranchiseName { get; set; } = String.Empty;
        public string Contact { get; set; } = String.Empty;

        public bool Validate()
        {
            EmailAddressAttribute e = new();
            return !string.IsNullOrWhiteSpace(FranchiseName) && e.IsValid(Contact);
        }
    }

}