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



string[] allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()
    ?? builder.Configuration["Cors__AllowedOrigins"]?.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
    ?? [];

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "DEFAULT", policy =>
    {
        if (allowedOrigins.Contains("*"))
        {
            policy.AllowAnyOrigin();
        }
        else
        {
            policy.WithOrigins(allowedOrigins);
        }
        policy.WithHeaders("Authorization","Content-Type","Accept","X-File-Token");
        policy.WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS");
    });
});

builder.Services.AddMemoryCache();

builder.Services.AddControllers(options =>
{
    options.ModelMetadataDetailsProviders.Add(
        new Microsoft.AspNetCore.Mvc.ModelBinding.Metadata.ExcludeBindingMetadataProvider(
            typeof(System.ComponentModel.ReadOnlyAttribute)
        )
    );
});

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(cfg =>
{
    cfg.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo { Title = "PetCenter API", Version = "v1" });

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



builder.Services.AddSingleton<IMessageBusClient, MessageBusClient>();


builder.Services.AddDbContext<PetCenterDBContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.EnableDetailedErrors();
    options.ConfigureWarnings(w => w.Ignore(RelationalEventId.MultipleCollectionIncludeWarning));
});

string? jwtValidIssuer = builder.Configuration["Jwt:Issuer"];
string? jwtValidAudience = builder.Configuration["Jwt:Audience"];
string? jwtKey = builder.Configuration["Jwt:Key"];

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidAlgorithms = new[] { SecurityAlgorithms.HmacSha256 },
            ValidateIssuer = true,
            ValidateAudience = true,
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
                string? jti = context.Principal?
                    .FindFirst(JwtRegisteredClaimNames.Jti)?.Value;

                if (jti == null || !Guid.TryParse(jti, out var parsedJti))
                {
                    context.Fail("Invalid token.");
                    return;
                }

                PetCenterDBContext db = context.HttpContext.RequestServices
                    .GetRequiredService<PetCenterDBContext>();

                bool isInvalidated = await db.InvalidatedTokens
                    .AnyAsync(t => t.Id == parsedJti
                                && t.Expiry <= DateTime.UtcNow);

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

string? contact = builder.Configuration["InstanceOwner:Contact"];
string? password = builder.Configuration["InstanceOwner:Password"];
bool seeder_static = bool.TryParse(builder.Configuration["Seeder:Static"], out bool result) && result;
bool hasSeed = int.TryParse(builder.Configuration["Seeder:Seed"], out int seed);

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
                AccountRequestDTO owner_req = new AccountRequestDTO()
                {
                    Contact = contact!,
                    Password = password!,
                };

                await svc.Post(Guid.Empty, Guid.Empty, owner_req);

                if (hasSeed)
                {
                    await seeder.SeedDatabase(ctx, !seeder_static, seed);
                }
                else
                {
                    await seeder.SeedDatabase(ctx, !seeder_static);
                }
            }

            await Task.Delay(2500);
        }
    }
    catch (Exception ex)
    {
        logger.LogTrace(ex, "Startup error.");
        retry = true;
        await Task.Delay(2500);
    }
}

app.MapControllers();

app.Run();