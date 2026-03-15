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

            string? e = Environment.GetEnvironmentVariable("APP_EMAIL");

            if (!string.IsNullOrWhiteSpace(e))
            {
                smtp.email = e;
            }

            string? usr = Environment.GetEnvironmentVariable("SMTP_USERNAME");

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

        public async Task SendEmail(string email,string message, string? subject, string? name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                name = "User";
            }

            if (string.IsNullOrWhiteSpace(subject))
            {
                subject = "Message from PetCenter!";
            }

            if (string.IsNullOrWhiteSpace(smtp.email))
            {
                smtp.email="null@example.com";
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
                    MailKit.Security.SecureSocketOptions security = (smtp.port == 1025) 
                    ? MailKit.Security.SecureSocketOptions.None 
                    : MailKit.Security.SecureSocketOptions.StartTls;

                    await client.ConnectAsync(smtp.server, smtp.port.GetValueOrDefault(1025), security);
                    if (!string.IsNullOrWhiteSpace(smtp.user) && !string.IsNullOrWhiteSpace(smtp.password))
                    {
                        await client.AuthenticateAsync(smtp.user, smtp.password);
                        await client.SendAsync(msg);
                    }
                   

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
