FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY Reactivities.sln ./
COPY API/API.csproj API/
COPY Application/Application.csproj Application/
COPY Domain/Domain.csproj Domain/
COPY Infrastructure/Infrastructure.csproj Infrastructure/
COPY Persistence/Persistence.csproj Persistence/

RUN dotnet restore

COPY . ./
RUN dotnet publish API/API.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

USER $APP_UID

EXPOSE 8080
ENTRYPOINT ["dotnet", "API.dll"]
