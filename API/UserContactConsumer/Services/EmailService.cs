using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;
using MimeKit;
using MailKit.Net.Smtp;

namespace UserContactConsumer.Services
{
    public class SmtpCfg
    {
        public string? email {  get; set; }
        public string? password { get; set; }
        public string? user {  get; set; }
        public string? server { get; set; }
        public int? port { get; set; }


    }

    public class EmailService
    {
        private readonly IConfiguration cfg;
        private readonly SmtpCfg smtp;

        public EmailService(IConfiguration c)
        {
            cfg = c;           

            IConfigurationSection email_cfg = cfg.GetSection("Email");
            int.TryParse(email_cfg["SmtpPort"], out int p);


            smtp = new()
            {
                email = email_cfg["ApplicationEmail"],
                port = p,
                user = email_cfg["SmtpUser"],
                password = email_cfg["SmtpPassword"],
                server = email_cfg["SmtpServer"]
            };

            string? e = Environment.GetEnvironmentVariable("SMTP_EMAIL");

            if (!string.IsNullOrWhiteSpace(e))
            {
                smtp.email = e;
            }

            string? usr = Environment.GetEnvironmentVariable("SMTP_USER");

            if (!string.IsNullOrWhiteSpace(usr))
            {
                smtp.user = usr;
            }

            string? s = Environment.GetEnvironmentVariable("SMTP_SERVER");

            if (!string.IsNullOrWhiteSpace(s))
            {
                smtp.server = s;
            }

            string? pwd = Environment.GetEnvironmentVariable("SMTP_PASSWORD");

            if (!string.IsNullOrWhiteSpace(pwd))
            {
                smtp.password = pwd;
            }

            if (int.TryParse(Environment.GetEnvironmentVariable("SMTP_PORT"), out int pt))
            {
                smtp.port = pt;
            }

        }

        public void SendEmail(string email,string message, string? subject, string? name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                name = "User";
            }

            if (string.IsNullOrWhiteSpace(subject))
            {
                subject = "Message from PetCenter!";
            }


            MimeMessage msg = new();
            msg.Subject = subject;
            msg.From.Add(new MailboxAddress("PetCenter", smtp.email));
            msg.To.Add(new MailboxAddress(name, email));
            msg.Body = new TextPart("plain"){ Text = message };

            using(SmtpClient client = new())
            {
                try
                {
                    client.Connect(smtp.server, smtp.port.GetValueOrDefault(587));
                    client.Authenticate(smtp.user, smtp.password);
                    client.Send(msg);

                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
                finally
                {
                    client.Disconnect(true);                   
                }
            }


        }

    }
}
