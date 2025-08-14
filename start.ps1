# Qwen Code Docker Startup Script (PowerShell)
# Configures environment and starts the Docker containers

param(
    [string]$OpenaiBaseUrl,
    [string]$OpenaiModel,
    [string]$OpenaiApiKey
)

# Error handling
$ErrorActionPreference = "Stop"

# Color functions for output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

try {
    Write-Info "Starting Qwen Code Docker Environment..."

    # Set default environment variables
    if (-not $OpenaiBaseUrl) {
        $OpenaiBaseUrl = if ($env:OPENAI_BASE_URL) { $env:OPENAI_BASE_URL } else { "http://localhost:11434/v1" }
    }
    
    if (-not $OpenaiModel) {
        $OpenaiModel = if ($env:OPENAI_MODEL) { $env:OPENAI_MODEL } else { "qwen3-coder:latest" }
    }

    if (-not $OpenaiApiKey) {
        $OpenaiApiKey = $env:OPENAI_API_KEY
    }

    # Set environment variables
    $env:OPENAI_BASE_URL = $OpenaiBaseUrl
    $env:OPENAI_MODEL = $OpenaiModel
    $env:OPENAI_API_KEY = $OpenaiApiKey

    # Display configuration
    Write-Info "Configuration:"
    Write-Host "  OPENAI_BASE_URL: $($env:OPENAI_BASE_URL)"
    Write-Host "  OPENAI_MODEL: $($env:OPENAI_MODEL)"
    if ($env:OPENAI_API_KEY) {
        Write-Host "  OPENAI_API_KEY: ***set***"
    } else {
        Write-Host "  OPENAI_API_KEY: ***not set***"
    }

    # Check if docker-compose.yml exists
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Error "docker-compose.yml not found in current directory"
        Write-Error "Please ensure you're running this script from the project root"
        exit 1
    }

    # Check if Docker is running
    try {
        & docker info | Out-Null
    } catch {
        Write-Error "Docker is not running or not accessible"
        Write-Error "Please start Docker Desktop and try again"
        exit 1
    }

    # Check if docker-compose is available
    $composeCmd = ""
    try {
        & docker-compose --version | Out-Null
        $composeCmd = "docker-compose"
    } catch {
        try {
            & docker compose version | Out-Null
            $composeCmd = "docker compose"
        } catch {
            Write-Error "docker-compose or 'docker compose' command not found"
            Write-Error "Please install Docker Compose and try again"
            exit 1
        }
    }

    Write-Info "Starting Docker containers..."

    # Start the containers
    $result = & $composeCmd up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start Docker containers"
        exit 1
    }

    Write-Success "Docker containers started successfully!"
    Write-Info "You can view logs with: $composeCmd logs -f"
    Write-Info "To stop containers: $composeCmd down"
    Write-Info "Access qwen-code CLI: $composeCmd exec qwen-code bash"
    Write-Success "Qwen Code environment is ready!"

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}