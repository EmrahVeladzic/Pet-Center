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
    public class AccountResponseDTO : IBaseResponseDTO<Account,AccountResponseDTO>
    {        

        public Guid? Id {get; set;}

        public string? Contact {get; set;}

        public Access AccessLevel {get; set;}

        public bool Verified {get; set;}

        public static AccountResponseDTO? FromEntity(Account? acc)
        {
            if(acc==null){return null;}

            return new AccountResponseDTO
            {
                Id=acc.Id,
                Contact = acc.Contact,
                AccessLevel = acc.AccessLevel,
                Verified = acc.Verified
            };
        }
    }
}
