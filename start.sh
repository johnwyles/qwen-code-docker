#!/bin/bash

# Qwen Code Docker Startup Script
# Configures environment and starts the Docker containers

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "Starting Qwen Code Docker Environment..."

# Set default environment variables
export OLLAMA_HOST=${OLLAMA_HOST:-"avi.alliance.unm.edu"}
export OLLAMA_PORT=${OLLAMA_PORT:-"8443"}

# Check if CUSTOM_ENDPOINT is provided, otherwise build from components
if [ -n "$CUSTOM_ENDPOINT" ]; then
    export OPENAI_BASE_URL="$CUSTOM_ENDPOINT"
    print_info "Using custom endpoint: $OPENAI_BASE_URL"
else
    export OPENAI_BASE_URL="https://${OLLAMA_HOST}:${OLLAMA_PORT}/v1"
    print_info "Built endpoint from components: $OPENAI_BASE_URL"
fi

# Display configuration
print_info "Configuration:"
echo "  OLLAMA_HOST: $OLLAMA_HOST"
echo "  OLLAMA_PORT: $OLLAMA_PORT"
echo "  OPENAI_BASE_URL: $OPENAI_BASE_URL"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found in current directory"
    print_error "Please ensure you're running this script from the project root"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running or not accessible"
    print_error "Please start Docker and try again"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    print_error "docker-compose or 'docker compose' command not found"
    print_error "Please install Docker Compose and try again"
    exit 1
fi

print_info "Starting Docker containers..."

# Use docker-compose or docker compose based on availability
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

# Start the containers
if $COMPOSE_CMD up -d; then
    print_success "Docker containers started successfully!"
    print_info "You can view logs with: $COMPOSE_CMD logs -f"
    print_info "To stop containers: $COMPOSE_CMD down"
else
    print_error "Failed to start Docker containers"
    exit 1
fi

print_success "Qwen Code environment is ready!"