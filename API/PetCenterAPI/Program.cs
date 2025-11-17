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
builder.Services.AddSwaggerGen();

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
            Email = instance_owner["Email"],
            PhoneNumber = null,
            Password = instance_owner["Password"],
        };

        await svc.Register(owner_req);

    }
}



app.MapControllers();


app.Run();
