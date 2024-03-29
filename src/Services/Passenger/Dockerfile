FROM mcr.microsoft.com/dotnet/sdk:8.0-preview AS builder
WORKDIR /

# Setup working directory for the project
COPY ./src/BuildingBlocks/BuildingBlocks.csproj ./BuildingBlocks/
COPY ./src/Services/Passenger/src/Passenger/Passenger.csproj ./Services/Passenger/src/Passenger/
COPY ./src/Services/Passenger/src/Passenger.Api/Passenger.Api.csproj ./Services/Passenger/src/Passenger.Api/


# Restore nuget packages
RUN dotnet restore ./Services/Passenger/src/Passenger.Api/Passenger.Api.csproj

# Copy project files
COPY ./src/BuildingBlocks ./BuildingBlocks/
COPY ./src/Services/Passenger/src/Passenger/  ./Services/Passenger/src/Passenger/
COPY ./src/Services/Passenger/src/Passenger.Api/  ./Services/Passenger/src/Passenger.Api/

# Build project with Release configuration
# and no restore, as we did it already
RUN dotnet build  -c Release --no-restore ./Services/Passenger/src/Passenger.Api/Passenger.Api.csproj

WORKDIR /Services/Passenger/src/Passenger.Api

# Publish project to output folder
# and no build, as we did it already
RUN dotnet publish -c Release --no-build -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0-preview
COPY --from=builder /Services/Passenger/src/Passenger.Api/out  /app
WORKDIR /app
RUN groupadd -g 10001 dotnet && \
   useradd -u 10000 -g dotnet dotnet \
   && chown -R dotnet:dotnet /app

USER 10000:10001

ENV ASPNETCORE_URLS http://*:8080
ENV ASPNETCORE_ENVIRONMENT docker

EXPOSE 8080

ENTRYPOINT ["dotnet", "Passenger.Api.dll"]

