using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.Requests
{
    public class UserRequestObject
    {
        public string? UserName { get; set; }
        public byte[]? Image { get; set; }
        public int? ImageWidth { get; set; }
        public int? ImageHeight { get; set; }
    }
}
