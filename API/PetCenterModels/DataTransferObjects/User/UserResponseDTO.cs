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
    public class UserResponseDTO : IDeserializableResponseDTO<User>
    {        
        public string? UserName {get; set;}

        public Guid AlbumId {get; set;}

        public UserResponseDTO(User? usr)
        {
            FromEntity(usr);
        }

        public void FromEntity(User? usr)
        {
            if (usr != null)
            {
                UserName = usr.UserName;

                AlbumId = usr.PictureId;
            }
        }
    }
}
