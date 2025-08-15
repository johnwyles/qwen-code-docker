#!/bin/bash

# Docker entrypoint script for qwen-code with optional Gemini-OpenAI bridge
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log function with colors
log() {
    local color=$1
    shift
    echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"
}

# Load environment variables from .env file if it exists
if [ -f /workspace/.env ]; then
    log $BLUE "Loading environment from /workspace/.env"
    export $(grep -v '^#' /workspace/.env | xargs)
fi

# Check if bridge should be used
USE_BRIDGE=${USE_GEMINI_BRIDGE:-false}
BRIDGE_PORT=${BRIDGE_PORT:-8080}
ORIGINAL_URL=${OPENAI_BASE_URL:-http://localhost:11434/v1}

log $CYAN "==========================================="
log $CYAN "Qwen-Code Docker Container Starting"
log $CYAN "==========================================="
log $BLUE "Use Bridge: $USE_BRIDGE"
log $BLUE "Original URL: $ORIGINAL_URL"

if [ "$USE_BRIDGE" = "true" ]; then
    log $YELLOW "Starting Gemini-OpenAI Bridge..."
    
    # Start bridge in background
    cd /bridge
    export BRIDGE_TARGET_URL=${BRIDGE_TARGET_URL:-$ORIGINAL_URL}
    export BRIDGE_PORT=$BRIDGE_PORT
    export BRIDGE_DEBUG=${BRIDGE_DEBUG:-false}
    
    log $BLUE "Bridge Target: $BRIDGE_TARGET_URL"
    log $BLUE "Bridge Port: $BRIDGE_PORT"
    
    # Start bridge server in background
    node bridge.js &
    BRIDGE_PID=$!
    
    # Wait a moment for bridge to start
    sleep 2
    
    # Test bridge health
    if curl -s http://localhost:$BRIDGE_PORT/health > /dev/null; then
        log $GREEN "✅ Bridge started successfully"
        
        # Update qwen-code to use bridge
        export OPENAI_BASE_URL="http://localhost:$BRIDGE_PORT/v1"
        log $BLUE "Redirecting qwen-code to: $OPENAI_BASE_URL"
    else
        log $RED "❌ Bridge failed to start"
        kill $BRIDGE_PID 2>/dev/null || true
        exit 1
    fi
    
    # Cleanup function for bridge
    cleanup() {
        log $YELLOW "Shutting down bridge..."
        kill $BRIDGE_PID 2>/dev/null || true
        exit 0
    }
    trap cleanup SIGTERM SIGINT
    
else
    log $BLUE "Using direct connection to: $ORIGINAL_URL"
fi

# Switch to workspace directory
cd /workspace

log $GREEN "✅ Container ready!"
log $CYAN "==========================================="

# Execute the command passed to the container
exec "$@"