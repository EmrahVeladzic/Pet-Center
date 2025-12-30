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
    public class AccountResponseDTO : IDeserializableResponseDTO<Account>
    {        
        public AccountResponseDTO(Account? acc)
        {
            FromEntity(acc);
        }

        public Guid AccountId {get; set;}

        public string? Contact {get; set;}

        public Access AccessLevel {get; set;}

        public bool Verified {get; set;}

        public void FromEntity(Account? acc)
        {
            if (acc != null)
            {
                AccountId = acc.Id;
                Contact = acc.Contact;
                AccessLevel = acc.AccessLevel;
                Verified = acc.Verified;
            }
        }
    }
}
