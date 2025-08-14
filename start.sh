#!/bin/bash

# Qwen Code Docker Intelligent Startup Script
# Handles container states, rebuilds, and data persistence

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

# Configuration
CONTAINER_NAME="qwen-code"
IMAGE_NAME="qwen-code-docker-qwen-code"
DOCKERFILE_PATH="./Dockerfile"

print_info "Starting Qwen Code Docker Environment..."

# Load .env file if it exists
if [ -f .env ]; then
    print_info "Loading environment from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default environment variables (only if not already set)
export OPENAI_BASE_URL=${OPENAI_BASE_URL:-"http://localhost:11434/v1"}
export OPENAI_MODEL=${OPENAI_MODEL:-"qwen3-coder:latest"}

# Display configuration
print_info "Configuration:"
echo "  OPENAI_BASE_URL: $OPENAI_BASE_URL"
echo "  OPENAI_MODEL: $OPENAI_MODEL"
echo "  OPENAI_API_KEY: ${OPENAI_API_KEY:+***set***}"

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

# Determine compose command
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    print_error "docker-compose or 'docker compose' command not found"
    print_error "Please install Docker Compose and try again"
    exit 1
fi

# Function to check if image needs rebuild
needs_rebuild() {
    # Check if image exists
    if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        print_info "Image does not exist, needs build"
        return 0  # Needs build
    fi
    
    # For simplicity, assume rebuild is needed if Dockerfile exists
    # (avoids complex timestamp comparison that can cause issues)
    if [ -f "$DOCKERFILE_PATH" ]; then
        print_info "Dockerfile exists, will check if rebuild needed"
        return 1  # No rebuild needed by default
    fi
    
    return 1  # No rebuild needed
}

# Function to check container state
get_container_state() {
    if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        docker container inspect "$CONTAINER_NAME" -f '{{.State.Status}}'
    else
        echo "missing"
    fi
}

# Function to rebuild image and recreate container
rebuild_and_recreate() {
    print_info "Rebuilding image and recreating container..."
    
    # Stop and remove container but keep volumes
    if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        print_info "Stopping and removing existing container..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    
    # Rebuild image
    print_info "Building new image..."
    $COMPOSE_CMD build --no-cache
    
    print_success "Image rebuilt successfully"
}

# Function to start container and exec into qwen
start_and_exec() {
    print_info "Starting container and launching qwen CLI..."
    $COMPOSE_CMD up -d
    sleep 2  # Give container time to start
    
    # Check if qwen command exists in container
    if docker exec "$CONTAINER_NAME" which qwen >/dev/null 2>&1; then
        print_success "Launching qwen CLI..."
        docker exec -it "$CONTAINER_NAME" qwen
    else
        print_error "qwen command not found in container"
        print_info "Dropping you into bash shell instead..."
        docker exec -it "$CONTAINER_NAME" bash
    fi
}

# Function to exec into running container
exec_into_running() {
    print_info "Container is running, connecting to qwen CLI..."
    
    # Check if qwen command exists in container
    if docker exec "$CONTAINER_NAME" which qwen >/dev/null 2>&1; then
        docker exec -it "$CONTAINER_NAME" qwen
    else
        print_error "qwen command not found in container"
        print_info "Dropping you into bash shell instead..."
        docker exec -it "$CONTAINER_NAME" bash
    fi
}

# Create empty gitconfig if it doesn't exist to prevent mount errors
if [ ! -f "$HOME/.gitconfig" ]; then
    print_info "Creating empty .gitconfig file for container mount"
    touch "$HOME/.gitconfig"
fi

# Main logic
print_info "Checking container and image status..."

CONTAINER_STATE=$(get_container_state)
print_info "Container state: $CONTAINER_STATE"

# Check if rebuild is needed
if needs_rebuild; then
    rebuild_and_recreate
    start_and_exec
else
    case "$CONTAINER_STATE" in
        "running")
            print_info "Container is already running"
            exec_into_running
            ;;
        "exited"|"stopped")
            print_info "Container exists but is stopped, starting it..."
            docker start "$CONTAINER_NAME"
            sleep 2  # Give container time to start
            exec_into_running
            ;;
        "missing")
            print_info "Container does not exist, creating it..."
            start_and_exec
            ;;
        "restarting")
            print_warning "Container is in restart loop, checking logs..."
            docker logs "$CONTAINER_NAME" --tail 20 2>&1 | sed 's/^/  /'
            print_info "Stopping and removing the failed container..."
            docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
            docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
            print_info "Rebuilding and starting fresh..."
            rebuild_and_recreate
            start_and_exec
            ;;
        *)
            print_warning "Unknown container state: $CONTAINER_STATE"
            print_info "Attempting to start container anyway..."
            start_and_exec
            ;;
    esac
fi