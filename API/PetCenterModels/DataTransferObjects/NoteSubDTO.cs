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

    public class NoteSubDTO : IGeneratedSubDTO
    {
        
        public string Title {get; set;} = string.Empty;
        public string Body {get; set;} = string.Empty;

    }


}