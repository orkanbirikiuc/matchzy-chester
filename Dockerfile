# Dockerfile for building MatchZy-Chester plugin
# Usage: docker build -t matchzy-chester . && docker run --rm -v $(pwd)/output:/output matchzy-chester

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copy project file first for layer caching
COPY MatchZy.csproj .

# Restore dependencies
RUN dotnet restore

# Copy all source files
COPY . .

# Build the plugin in Release mode
RUN dotnet build -c Release -o /app/build

# Create output stage
FROM scratch AS export

# Copy the built artifacts
COPY --from=build /app/build /

# For running the container to extract files
FROM alpine:latest AS runtime

WORKDIR /output

# Copy the build artifacts
COPY --from=build /app/build /build

# Default command copies build output to /output volume
CMD ["sh", "-c", "cp -r /build/* /output/ && echo 'Build artifacts copied to /output'"]
