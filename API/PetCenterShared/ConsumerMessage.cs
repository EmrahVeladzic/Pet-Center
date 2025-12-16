using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PetCenterShared
{
    public class ConsumerMessage
    {
        public string Contact {  get; set; } = String.Empty;
        public string Message { get; set; } = String.Empty;
        public string? Subject { get; set; }
        public string? Name { get; set; }
    }
}
