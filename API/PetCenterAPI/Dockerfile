# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["API/PetCenterAPI/PetCenterAPI.csproj", "API/PetCenterAPI/"]
COPY ["API/PetCenterModels/PetCenterModels.csproj", "API/PetCenterModels/"]
COPY ["API/PetCenterServices/PetCenterServices.csproj", "API/PetCenterServices/"]
COPY ["API/PetCenterShared/PetCenterShared.csproj", "API/PetCenterShared/"]
RUN dotnet restore "API/PetCenterAPI/PetCenterAPI.csproj"
COPY . .
WORKDIR "/src/API/PetCenterAPI"
RUN dotnet build "PetCenterAPI.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "PetCenterAPI.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PetCenterAPI.dll"]