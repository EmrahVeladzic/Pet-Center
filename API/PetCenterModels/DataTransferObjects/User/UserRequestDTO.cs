using System;
using System.Collections.Generic;
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

        public string UserName { get; set; } = string.Empty;


        public bool Validate()
        {
            return (!string.IsNullOrWhiteSpace(UserName));           
        }
        
    }
}
