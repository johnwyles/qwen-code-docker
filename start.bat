@echo off
REM Qwen Coder Docker Startup Script (Windows Batch)
REM Configures environment and starts the Docker containers

setlocal enabledelayedexpansion

echo [INFO] Starting Qwen Coder Docker Environment...

REM Set default environment variables if not already set
if not defined OLLAMA_HOST set OLLAMA_HOST=avi.alliance.unm.edu
if not defined OLLAMA_PORT set OLLAMA_PORT=8443

REM Check if CUSTOM_ENDPOINT is provided, otherwise build from components
if defined CUSTOM_ENDPOINT (
    set OPENAI_BASE_URL=%CUSTOM_ENDPOINT%
    echo [INFO] Using custom endpoint: !OPENAI_BASE_URL!
) else (
    set OPENAI_BASE_URL=https://%OLLAMA_HOST%:%OLLAMA_PORT%/v1
    echo [INFO] Built endpoint from components: !OPENAI_BASE_URL!
)

REM Display configuration
echo [INFO] Configuration:
echo   OLLAMA_HOST: %OLLAMA_HOST%
echo   OLLAMA_PORT: %OLLAMA_PORT%
echo   OPENAI_BASE_URL: !OPENAI_BASE_URL!

REM Check if docker-compose.yml exists
if not exist "docker-compose.yml" (
    echo [ERROR] docker-compose.yml not found in current directory
    echo [ERROR] Please ensure you're running this script from the project root
    exit /b 1
)

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running or not accessible
    echo [ERROR] Please start Docker Desktop and try again
    exit /b 1
)

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] docker-compose or 'docker compose' command not found
        echo [ERROR] Please install Docker Compose and try again
        exit /b 1
    ) else (
        set COMPOSE_CMD=docker compose
    )
) else (
    set COMPOSE_CMD=docker-compose
)

echo [INFO] Starting Docker containers...

REM Start the containers
!COMPOSE_CMD! up -d
if errorlevel 1 (
    echo [ERROR] Failed to start Docker containers
    exit /b 1
)

echo [SUCCESS] Docker containers started successfully!
echo [INFO] You can view logs with: !COMPOSE_CMD! logs -f
echo [INFO] To stop containers: !COMPOSE_CMD! down
echo [SUCCESS] Qwen Coder environment is ready!

pause