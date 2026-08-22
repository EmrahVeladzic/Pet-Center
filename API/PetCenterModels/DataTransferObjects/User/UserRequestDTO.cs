using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;

namespace PetCenterModels.DataTransferObjects
{
    public class UserRequestDTO : IBaseRequestDTO
    {
        public Guid? Id {get;set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        [MaxLength(75)]
        public string UserName { get; set; } = string.Empty;


        public string? Validate()
        {
            return string.IsNullOrWhiteSpace(UserName)? "Usernames may not be empty.": null;           
        }
        
    }
}
