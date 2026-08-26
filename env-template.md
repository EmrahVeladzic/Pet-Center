# You may use this template to set up a .env file:
# Values shown are safe local-development defaults for `docker compose up`.
# Anything written as CHANGE_ME or example.com is a placeholder — replace it.

# API
InstanceOwner__Contact=owner@example.com
InstanceOwner__Password=CHANGE_ME_owner_password
API_MEM_LIMIT=512M
API_MEM_RESERVE=256M
CONSUMER_MEM_LIMIT=256M
CONSUMER_MEM_RESERVE=128M
Jwt__Key=CHANGE_ME_use_at_least_32_characters_long
Jwt__Issuer=https://localhost:8080
Jwt__Audience=https://localhost:8080
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_HTTP_PORTS=8080
Seeder__Seed=12345
Seeder__Static=true
Cors__AllowedOrigins=http://localhost:3000;http://localhost:8080

# RabbitMQ
RABBITMQ_DEFAULT_USER=guest
RABBITMQ_DEFAULT_PASS=guest
RABBITMQ_MEM_LIMIT=512M
RABBITMQ_MEM_RESERVE=256M
RabbitMQ__HostName=rabbitmq
RabbitMQ__QueueName=petcenter-contact
RabbitMQ__UserName=guest
RabbitMQ__Password=guest

# SMTP
# Defaults target the bundled MailHog container.
# Web UI: http://localhost:8025 — no real mail is sent.
Email__SmtpServer=mailhog
Email__SmtpPort=1025
Email__SmtpUser=
Email__SmtpPassword=
Email__ApplicationEmail=no-reply@example.com

# SQL
SA_PASSWORD=CHANGE_ME_Str0ng_P@ssw0rd
MSSQL_PID=Developer
DB_NAME=PetCenterDB
MSSQL_MEM_LIMIT=4G
MSSQL_MEM_RESERVE=2G
ConnectionStrings__DefaultConnection=Server=mssql,1433;Database=PetCenterDB;User Id=sa;Password=CHANGE_ME_Str0ng_P@ssw0rd;TrustServerCertificate=True;

# Notes
# - SA_PASSWORD must satisfy SQL Server's policy: 8+ characters with upper,
#   lower, digit and symbol. It must match the password inside
#   ConnectionStrings__DefaultConnection.
# - Jwt__Key is the HMAC signing key; short keys are rejected at startup.
# - Seeder__Seed must parse as an integer, Seeder__Static as a boolean.
# - Cors__AllowedOrigins is a semicolon-separated list.
# - Host names (mssql, rabbitmq, mailhog) are docker-compose service names.
#   Running outside compose, use localhost with the mapped ports instead.