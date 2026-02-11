using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DataTransferObjects;
using PetCenterModels.DBTables;


namespace PetCenterModels.DataTransferObjects
{
    public class UserResponseDTO : IBaseResponseDTO<User,UserResponseDTO>
    {        
        public Guid? Id {get; set;}
        public string? UserName {get; set;}
        public List<NoteSubDTO>? Notes {get; set;}

        public static UserResponseDTO? FromEntity(User? usr)
        {
            if (usr==null){return null;}

            return new UserResponseDTO
            {
                Id=usr.Id,
                UserName=usr.UserName,
               
            };
        }
    }
}
