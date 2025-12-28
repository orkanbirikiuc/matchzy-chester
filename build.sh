#!/bin/bash
# Build script for MatchZy-Chester plugin
# Builds the plugin using dotnet or Docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
BUILD_MODE="dotnet"
CONFIGURATION="Release"

while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)
            BUILD_MODE="docker"
            shift
            ;;
        --debug)
            CONFIGURATION="Debug"
            shift
            ;;
        --clean)
            echo_info "Cleaning build artifacts..."
            rm -rf "${SCRIPT_DIR}/bin" "${SCRIPT_DIR}/obj" "${OUTPUT_DIR}"
            echo_info "Clean complete"
            exit 0
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --docker    Build using Docker instead of local dotnet SDK"
            echo "  --debug     Build in Debug configuration (default: Release)"
            echo "  --clean     Clean build artifacts and exit"
            echo "  -h, --help  Show this help message"
            exit 0
            ;;
        *)
            echo_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create output directory
mkdir -p "${OUTPUT_DIR}"

if [ "$BUILD_MODE" == "docker" ]; then
    echo_info "Building with Docker..."

    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        echo_error "Docker is not installed or not in PATH"
        exit 1
    fi

    # Build the Docker image
    echo_info "Building Docker image..."
    docker build -t matchzy-chester:build "${SCRIPT_DIR}"

    # Run the container to extract build artifacts
    echo_info "Extracting build artifacts..."
    docker run --rm -v "${OUTPUT_DIR}:/output" matchzy-chester:build

    echo_info "Build artifacts available in: ${OUTPUT_DIR}"

else
    echo_info "Building with dotnet SDK..."

    # Check if dotnet is available
    if ! command -v dotnet &> /dev/null; then
        echo_error "dotnet SDK is not installed or not in PATH"
        echo_warn "Try building with Docker: $0 --docker"
        exit 1
    fi

    # Check dotnet version
    DOTNET_VERSION=$(dotnet --version)
    echo_info "Using dotnet version: ${DOTNET_VERSION}"

    # Restore dependencies
    echo_info "Restoring dependencies..."
    dotnet restore "${SCRIPT_DIR}/MatchZy.csproj"

    # Build the project
    echo_info "Building in ${CONFIGURATION} mode..."
    dotnet build "${SCRIPT_DIR}/MatchZy.csproj" -c "${CONFIGURATION}" -o "${OUTPUT_DIR}"

    echo_info "Build complete!"
fi

# List output files
echo ""
echo_info "Build output:"
ls -la "${OUTPUT_DIR}"

echo ""
echo_info "To install, copy the contents of ${OUTPUT_DIR} to your CS2 server's"
echo_info "game/csgo/addons/counterstrikesharp/plugins/MatchZy/ directory"
