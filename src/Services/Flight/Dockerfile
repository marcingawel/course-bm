FROM mcr.microsoft.com/dotnet/sdk:8.0-preview AS builder
WORKDIR /

# Setup working directory for the project
COPY ./src/BuildingBlocks/BuildingBlocks.csproj ./BuildingBlocks/
COPY ./src/Services/Flight/src/Flight/Flight.csproj ./Services/Flight/src/Flight/
COPY ./src/Services/Flight/src/Flight.Api/Flight.Api.csproj ./Services/Flight/src/Flight.Api/


# Restore nuget packages
RUN dotnet restore ./Services/Flight/src/Flight.Api/Flight.Api.csproj

# Copy project files
COPY ./src/BuildingBlocks ./BuildingBlocks/
COPY ./src/Services/Flight/src/Flight/  ./Services/Flight/src/Flight/
COPY ./src/Services/Flight/src/Flight.Api/  ./Services/Flight/src/Flight.Api/

# Build project with Release configuration
# and no restore, as we did it already
RUN dotnet build  -c Release --no-restore ./Services/Flight/src/Flight.Api/Flight.Api.csproj

WORKDIR /Services/Flight/src/Flight.Api

# Publish project to output folder
# and no build, as we did it already
RUN dotnet publish -c Release --no-build -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0-preview
COPY --from=builder /Services/Flight/src/Flight.Api/out  /app
WORKDIR /app
RUN groupadd -g 10001 dotnet && \
   useradd -u 10000 -g dotnet dotnet \
   && chown -R dotnet:dotnet /app

USER 10000:10001

ENV ASPNETCORE_URLS http://*:8080
ENV ASPNETCORE_ENVIRONMENT docker

EXPOSE 8080

ENTRYPOINT ["dotnet", "Flight.Api.dll"]

