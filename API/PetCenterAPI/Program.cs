using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.DBTables;
using PetCenterModels.Requests;
using PetCenterServices;
using PetCenterServices.Interfaces;
using PetCenterServices.Services;
using PetCenterServices.Utils;
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
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IImageService, ImageService>();
builder.Services.AddScoped<IFranchiseService, FranchiseService>();

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

builder.Services.AddSingleton<IAuthorizationHandler, VerificationHandler>();

builder.Services.AddAuthorization(options =>
{
    options.DefaultPolicy = new AuthorizationPolicyBuilder()
        .AddRequirements(new VerificationRequirement())
        .Build();

    options.FallbackPolicy = options.DefaultPolicy;
});

PetCenterServices.Utils.Crypto.Configuration = builder.Configuration;

var app = builder.Build();

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var ex = context.Features
        .Get<IExceptionHandlerFeature>()?
        .Error;

        if (app.Environment.IsDevelopment() && ex != null)
        {
            Console.WriteLine($"[ERROR] {ex.GetType().Name}: {ex.Message}");
        }
        

        context.Response.StatusCode = 500;
        await context.Response.WriteAsync("Internal server error.");
    });
});


app.UseRouting();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseHttpsRedirection();
}


app.UseCors("DEFAULT");


app.UseAuthentication();

app.UseAuthorization();


bool retry = true;
while (retry)
{
    try
    {
        
        retry = false;

        using (IServiceScope scope = app.Services.CreateScope())
        {
            PetCenterDBContext ctx = scope.ServiceProvider.GetRequiredService<PetCenterDBContext>();
            IAccountService svc = scope.ServiceProvider.GetRequiredService<IAccountService>();
            
                    
                if (!await ctx.Accounts.AnyAsync())
                {

                    IConfigurationSection instance_owner = builder.Configuration.GetSection("InstanceOwner");
                    AccountRequestDTO owner_req = new AccountRequestDTO(){
                        Contact = instance_owner["Contact"]??"Null@example.com",            
                        Password = instance_owner["Password"]??"Null",
                    };

                    string? contact = Environment.GetEnvironmentVariable("INSTANCE_OWNER_CONTACT");
                    string? password = Environment.GetEnvironmentVariable("INSTANCE_OWNER_PASSWORD");

                    if (!string.IsNullOrWhiteSpace(contact) && !string.IsNullOrWhiteSpace(password)){

                        owner_req.Contact = contact;
                        owner_req.Password = password;

                    }


                    await svc.Post(null,owner_req);
                  
                }

                await Task.Delay(2500);

            }
    }
    catch
    {
        retry = true;
        await Task.Delay(2500);
    }

}
    




app.MapControllers();


app.Run();
