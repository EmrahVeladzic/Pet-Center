using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.Requests;
using PetCenterServices;
using PetCenterServices.Interfaces;
using PetCenterServices.Services;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "DEFAULT", policy =>
    {

        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();

    });

});

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(cfg =>
{
    cfg.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo { Title = "PetCenter API", Version = "v1" });

    // Add JWT Authentication
    cfg.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,       
    });

    cfg.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

builder.Services.AddScoped<IAccountService, AccountService>();

builder.Services.AddDbContext<PetCenterDBContext>(options =>
{

    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));

});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = false,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddAuthorization();

PetCenterServices.Utils.Crypto.Configuration = builder.Configuration;

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseRouting();

app.UseHttpsRedirection();

app.UseCors("DEFAULT");


app.UseAuthentication();

app.UseAuthorization();

using (IServiceScope scope = app.Services.CreateScope())
{
    PetCenterDBContext ctx = scope.ServiceProvider.GetRequiredService<PetCenterDBContext>();
    IAccountService svc = scope.ServiceProvider.GetRequiredService<IAccountService>();


    if (!ctx.Accounts.Any())
    {

        IConfigurationSection instance_owner = builder.Configuration.GetSection("InstanceOwner");
        AccountRequestObject owner_req = new AccountRequestObject()
        {
            Contact = instance_owner["Contact"],            
            Password = instance_owner["Password"],
        };

        string? contact = Environment.GetEnvironmentVariable("INSTANCE_OWNER_CONTACT");
        string? password = Environment.GetEnvironmentVariable("INSTANCE_OWNER_PASSWORD");

        if (!string.IsNullOrEmpty(contact) && !string.IsNullOrEmpty(password)){

            owner_req.Contact = contact;
            owner_req.Password = password;

        }


        await svc.Register(owner_req);

    }
}



app.MapControllers();


app.Run();
