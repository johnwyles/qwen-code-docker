@echo off
REM Qwen Code Docker Startup Script (Windows Batch)
REM Configures environment and starts the Docker containers

setlocal enabledelayedexpansion

echo [INFO] Starting Qwen Code Docker Environment...

REM Set default environment variables if not already set
if not defined OPENAI_BASE_URL set OPENAI_BASE_URL=http://localhost:11434/v1
if not defined OPENAI_MODEL set OPENAI_MODEL=qwen3-coder:latest

REM Display configuration
echo [INFO] Configuration:
echo   OPENAI_BASE_URL: !OPENAI_BASE_URL!
echo   OPENAI_MODEL: !OPENAI_MODEL!
if defined OPENAI_API_KEY (
    echo   OPENAI_API_KEY: ***set***
) else (
    echo   OPENAI_API_KEY: ***not set***
)

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
echo [INFO] Access qwen-code CLI: !COMPOSE_CMD! exec qwen-code bash
echo [SUCCESS] Qwen Code environment is ready!

pause