# Qwen Coder Docker Startup Script (PowerShell)
# Configures environment and starts the Docker containers

param(
    [string]$OllamaHost,
    [string]$OllamaPort,
    [string]$CustomEndpoint
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
    Write-Info "Starting Qwen Coder Docker Environment..."

    # Set default environment variables
    if (-not $OllamaHost) {
        $OllamaHost = if ($env:OLLAMA_HOST) { $env:OLLAMA_HOST } else { "avi.alliance.unm.edu" }
    }
    
    if (-not $OllamaPort) {
        $OllamaPort = if ($env:OLLAMA_PORT) { $env:OLLAMA_PORT } else { "8443" }
    }

    # Set environment variables
    $env:OLLAMA_HOST = $OllamaHost
    $env:OLLAMA_PORT = $OllamaPort

    # Check if CUSTOM_ENDPOINT is provided, otherwise build from components
    if ($CustomEndpoint -or $env:CUSTOM_ENDPOINT) {
        $endpoint = if ($CustomEndpoint) { $CustomEndpoint } else { $env:CUSTOM_ENDPOINT }
        $env:OPENAI_BASE_URL = $endpoint
        Write-Info "Using custom endpoint: $($env:OPENAI_BASE_URL)"
    } else {
        $env:OPENAI_BASE_URL = "https://$($env:OLLAMA_HOST):$($env:OLLAMA_PORT)/v1"
        Write-Info "Built endpoint from components: $($env:OPENAI_BASE_URL)"
    }

    # Display configuration
    Write-Info "Configuration:"
    Write-Host "  OLLAMA_HOST: $($env:OLLAMA_HOST)"
    Write-Host "  OLLAMA_PORT: $($env:OLLAMA_PORT)"
    Write-Host "  OPENAI_BASE_URL: $($env:OPENAI_BASE_URL)"

    # Check if docker-compose.yml exists
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Error "docker-compose.yml not found in current directory"
        Write-Error "Please ensure you're running this script from the project root"
        exit 1
    }

    # Check if Docker is running
    try {
        $null = docker info 2>$null
    } catch {
        Write-Error "Docker is not running or not accessible"
        Write-Error "Please start Docker Desktop and try again"
        exit 1
    }

    # Check if docker-compose is available and determine command
    $composeCmd = $null
    try {
        $null = docker-compose --version 2>$null
        $composeCmd = "docker-compose"
    } catch {
        try {
            $null = docker compose version 2>$null
            $composeCmd = "docker", "compose"
        } catch {
            Write-Error "docker-compose or 'docker compose' command not found"
            Write-Error "Please install Docker Compose and try again"
            exit 1
        }
    }

    Write-Info "Starting Docker containers..."

    # Start the containers
    if ($composeCmd -is [array]) {
        $process = Start-Process -FilePath $composeCmd[0] -ArgumentList ($composeCmd[1], "up", "-d") -Wait -PassThru -NoNewWindow
    } else {
        $process = Start-Process -FilePath $composeCmd -ArgumentList "up", "-d" -Wait -PassThru -NoNewWindow
    }

    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to start Docker containers"
        exit 1
    }

    Write-Success "Docker containers started successfully!"
    
    if ($composeCmd -is [array]) {
        $logCmd = "$($composeCmd[0]) $($composeCmd[1]) logs -f"
        $stopCmd = "$($composeCmd[0]) $($composeCmd[1]) down"
    } else {
        $logCmd = "$composeCmd logs -f"
        $stopCmd = "$composeCmd down"
    }
    
    Write-Info "You can view logs with: $logCmd"
    Write-Info "To stop containers: $stopCmd"
    Write-Success "Qwen Coder environment is ready!"

} catch {
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}

# Pause equivalent for PowerShell
Read-Host "Press Enter to continue..."