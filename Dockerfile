# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Install Node.js and create a non-root user
RUN apt-get update \
    && apt-get -y install nodejs \
    && useradd -r -u 1000 suraj

# Switch to the non-root user
USER suraj

# Copy the application files
COPY . ./
RUN dotnet restore \
    && dotnet build "dotnet6.csproj" -c Release \
    && dotnet publish "dotnet6.csproj" -c Release -o publish


# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app

# Copy the published output from the build stage
COPY --from=build /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS http://*:5000

# Expose the port on which the application listens
EXPOSE 5000

# Switch to the non-root user
USER suraj

# Set the entry point to start the application
ENTRYPOINT ["dotnet", "dotnet6.dll"]
