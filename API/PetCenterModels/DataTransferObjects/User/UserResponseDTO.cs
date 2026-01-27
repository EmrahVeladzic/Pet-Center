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
    public class UserResponseDTO : IBaseResponseDTO<User,UserResponseDTO>
    {        
        public Guid? Id {get; set;}
        public string? UserName {get; set;}

        public Guid AlbumId {get; set;}

        public static UserResponseDTO? FromEntity(User? usr)
        {
            if (usr==null){return null;}

            return new UserResponseDTO
            {
                Id=usr.Id,
                UserName=usr.UserName,
                AlbumId = usr.AlbumId
            };
        }
    }
}
