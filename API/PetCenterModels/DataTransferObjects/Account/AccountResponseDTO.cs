using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using PetCenterModels.DBTables;


namespace PetCenterModels.DataTransferObjects
{
    public class AccountResponseDTO : IBaseResponseDTO<Account,AccountResponseDTO>
    {        

        public Guid? Id {get; set;}

        public byte[] CurrentVersion { get; set; } = Array.Empty<byte>();

        public string Contact {get; set;} = string.Empty;

        public Access AccessLevel {get; set;}

        public bool Verified {get; set;}

        public List<NoteSubDTO>? Notes {get; set;}

        public static AccountResponseDTO? FromEntity(Account? acc)
        {
            if(acc==null){return null;}

            return new AccountResponseDTO
            {
                CurrentVersion=acc.CurrentVersion,
                Id=acc.Id,
                Contact = acc.Contact,
                AccessLevel = acc.AccessLevel,
                Verified = acc.Verified
            };
        }
    }
}
