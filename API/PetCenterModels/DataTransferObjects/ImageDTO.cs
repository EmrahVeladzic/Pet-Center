using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterModels.DataTransferObjects
{
    public class ImageDTO
    {
        public Guid? AlbumInsertId { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }
        public string? Data { get; set; }

    }
}
