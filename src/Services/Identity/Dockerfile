FROM mcr.microsoft.com/dotnet/sdk:8.0-preview AS builder

# Setup working directory for the project
WORKDIR /
COPY ./src/BuildingBlocks/BuildingBlocks.csproj ./BuildingBlocks/
COPY ./src/Services/Identity/src/Identity/Identity.csproj ./Services/Identity/src/Identity/
COPY ./src/Services/Identity/src/Identity.Api/Identity.Api.csproj ./Services/Identity/src/Identity.Api/

# Restore nuget packages
RUN dotnet restore ./Services/Identity/src/Identity.Api/Identity.Api.csproj

# Copy project files
COPY ./src/BuildingBlocks ./BuildingBlocks/
COPY ./src/Services/Identity/src/Identity/  ./Services/Identity/src/Identity/
COPY ./src/Services/Identity/src/Identity.Api/  ./Services/Identity/src/Identity.Api/

# Build project with Release configuration
# and no restore, as we did it already

RUN dotnet build  -c Release --no-restore ./Services/Identity/src/Identity.Api/Identity.Api.csproj

WORKDIR /Services/Identity/src/Identity.Api

# Publish project to output folder
# and no build, as we did it already
RUN dotnet publish -c Release --no-build -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0-preview
COPY --from=builder /Services/Identity/src/Identity.Api/out  /app
WORKDIR /app
RUN groupadd -g 10001 dotnet && \
   useradd -u 10000 -g dotnet dotnet \
   && chown -R dotnet:dotnet /app

USER 10000:10001

ENV ASPNETCORE_URLS http://*:8080
ENV ASPNETCORE_ENVIRONMENT docker

EXPOSE 8080

ENTRYPOINT ["dotnet", "Identity.Api.dll"]

