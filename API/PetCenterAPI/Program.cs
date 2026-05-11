using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PetCenterModels.DBTables;
using PetCenterModels.DataTransferObjects;
using PetCenterServices;
using PetCenterServices.Interfaces;
using PetCenterServices.Services;
using PetCenterServices.Utils;
using System.Text;
using System.Text.Json;
using PetCenterServices.Recommender;
using PetCenterServices.Workers;
using PetCenterServices.Seeder;
using Microsoft.EntityFrameworkCore.Diagnostics;
using System.IdentityModel.Tokens.Jwt;


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

    // Main JWT
    cfg.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
    });

    
    cfg.AddSecurityDefinition("FileToken", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "X-File-Token",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "File context token for BLOB operations"
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
        },
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "FileToken"
                }
            },
            new string[] {}
        }
    });

    cfg.SchemaFilter<CurrentVersionSchemaFilter>();
});


builder.Services.AddSingleton<IRecommenderSystem,RecommenderSystem>();
builder.Services.AddSingleton<ISeeder,TestSeeder>();


builder.Services.AddHostedService<CleanupService>();
builder.Services.AddHostedService<SupplyService>();

builder.Services.AddScoped<IAccountService, AccountService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IImageService, ImageService>();
builder.Services.AddScoped<IFranchiseService, FranchiseService>();
builder.Services.AddScoped<IFacilityService, FacilityService>();
builder.Services.AddScoped<IKindService, KindService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IFormTemplateService,FormTemplateService>();
builder.Services.AddScoped<ILivingConditionFieldService,LivingconditionFieldService>();
builder.Services.AddScoped<IItemService,ItemService>();
builder.Services.AddScoped<IBreedService,BreedService>();
builder.Services.AddScoped<IIndividualService,IndividualService>();
builder.Services.AddScoped<IProcedureService,ProcedureService>();
builder.Services.AddScoped<IFormService,FormService>();
builder.Services.AddScoped<IListingService,ListingService>();

builder.Services.AddScoped<IMessageBusClient, MessageBusClient>();

string? dbConnection = builder.Configuration.GetConnectionString("DefaultConnection");
dbConnection= Environment.GetEnvironmentVariable("DB_CONNECTION_STRING")??dbConnection;

builder.Services.AddDbContext<PetCenterDBContext>(options =>
{

    options.UseSqlServer(dbConnection);

    
    options.EnableDetailedErrors();
    

    options.ConfigureWarnings(w =>  w.Ignore(RelationalEventId.MultipleCollectionIncludeWarning));

});

string? jwtValidIssuer = builder.Configuration["Jwt:Issuer"];
string? jwtValidAudience = builder.Configuration["Jwt:Audience"];
string? jwtKey = builder.Configuration["Jwt:Key"];

jwtValidIssuer=Environment.GetEnvironmentVariable("JWT_ISSUER")??jwtValidIssuer;
jwtValidAudience=Environment.GetEnvironmentVariable("JWT_AUDIENCE")??jwtValidAudience;
jwtKey=Environment.GetEnvironmentVariable("JWT_KEY")??jwtKey;

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = false,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtValidIssuer,
            ValidAudience = jwtValidAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey!))
        };

        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = async context =>
            {
                var jti = context.Principal?
                    .FindFirst(JwtRegisteredClaimNames.Jti)?.Value;

              
                if (jti == null || !Guid.TryParse(jti, out var parsedJti))
                {
                    context.Fail("Invalid token.");
                    return;
                }

                var db = context.HttpContext.RequestServices
                    .GetRequiredService<PetCenterDBContext>();

                var isInvalidated = await db.InvalidatedTokens
                    .AnyAsync(t => t.Id == parsedJti
                                && t.Expiry > DateTime.UtcNow);

                if (isInvalidated)
                {
                    context.Fail("Token has been invalidated.");
                }
            }
        };
    });

builder.Services.AddSingleton<IAuthorizationHandler, VerificationHandler>();

builder.Services.AddAuthorization(options =>
{
    options.DefaultPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .RequireRole("Admin", "Owner", "Employee", "User")
        .AddRequirements(new VerificationRequirement())
        .Build();

    options.FallbackPolicy = options.DefaultPolicy;
});

PetCenterServices.Utils.Crypto.Configuration = builder.Configuration;

var app = builder.Build();

ILogger<Program> logger = app.Services.GetRequiredService<ILogger<Program>>();



app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        Exception? ex = context.Features.Get<IExceptionHandlerFeature>()?.Error;
        ServiceOutput<object> output = ServiceOutput<object>.FromException(ex, logger);
        await PetCenterAPI.Controllers.ResultConverter.WriteAsync(context, output);
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
            ISeeder seeder = scope.ServiceProvider.GetRequiredService<ISeeder>();
                    
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


                    await svc.Post(Guid.Empty,owner_req);

                    bool seeder_static =bool.TryParse(Environment.GetEnvironmentVariable("SEEDER_STATIC"), out var result)&& result;

                    if(int.TryParse(Environment.GetEnvironmentVariable("SEEDER_SEED"),out int seed))
                    {
                        await seeder.SeedDatabase(ctx,!seeder_static,seed);
                    
                    }
                    else
                    {
                        await seeder.SeedDatabase(ctx,!seeder_static);
                    }

                   
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
