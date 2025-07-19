@echo off
REM VSS Docker Management Script - Windows Version

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="build" goto build
if "%1"=="dev" goto dev
if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="status" goto status
if "%1"=="logs" goto logs
if "%1"=="clean" goto clean
if "%1"=="health" goto health
if "%1"=="backup" goto backup
if "%1"=="config" goto config
goto help

:help
echo.
echo ======= VSS Docker Management Tool =======
echo.
echo Usage: docker-manage.bat [command] [params]
echo.
echo Commands:
echo   build [env]  - Build images (dev/prod)
echo   dev          - Start development environment
echo   start        - Start production environment
echo   stop         - Stop all services
echo   restart      - Restart services
echo   status       - Show service status
echo   logs [svc]   - Show logs
echo   clean        - Clean resources
echo   health       - Health check
echo   backup       - Data backup
echo   config       - Configuration management
echo   help         - Show help
echo.
echo Environments:
echo   dev   - Development (hot reload, debug)
echo   prod  - Production (optimized, stable)
echo.
echo Examples:
echo   docker-manage.bat build dev
echo   docker-manage.bat dev
echo   docker-manage.bat logs frontend
echo.
goto end

:build
set BUILD_ENV=%2
if "%BUILD_ENV%"=="" set BUILD_ENV=dev
echo Building %BUILD_ENV% environment images...
if "%BUILD_ENV%"=="dev" (
    docker-compose -f docker-compose.dev.yml build --no-cache
) else (
    docker-compose -f docker-compose.yml build --no-cache
)
echo Image build completed
goto end

:dev
echo Starting development environment...
docker-compose -f docker-compose.dev.yml up -d
echo Development environment started
echo Frontend: http://localhost:3001
echo Backend: http://localhost:3003
goto end

:start
echo Starting production environment...
docker-compose up -d
echo Production environment started
echo Frontend: http://localhost:3000
echo Backend: http://localhost:3002
goto end

:stop
echo Stopping all services...
docker-compose -f docker-compose.dev.yml down
docker-compose down
echo Services stopped
goto end

:restart
echo Restarting services...
call :stop
timeout /t 3 /nobreak >nul
docker-compose up -d
echo Services restarted
goto end

:status
echo Service status:
docker-compose ps
echo.
echo Storage usage:
docker system df
goto end

:logs
set SERVICE=%2
if "%SERVICE%"=="" (
    docker-compose logs -f --tail=100
) else (
    docker-compose logs -f --tail=100 %SERVICE%
)
goto end

:clean
echo Cleaning Docker resources...
echo.
echo Select cleanup level:
echo 1) Light cleanup (stopped containers)
echo 2) Medium cleanup (+ unused images)
echo 3) Deep cleanup (+ all unused data)
echo.
set /p clean_level=Choose (1-3): 

if "%clean_level%"=="1" (
    docker container prune -f
    docker network prune -f
    echo Light cleanup completed
) else if "%clean_level%"=="2" (
    docker container prune -f
    docker network prune -f
    docker image prune -f
    echo Medium cleanup completed
) else if "%clean_level%"=="3" (
    docker system prune -a -f --volumes
    echo Deep cleanup completed
) else (
    echo Invalid choice
)
goto end

:health
echo System health check...
echo.
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not running
    goto end
)
echo Docker is running normally
echo.
echo Port check:
netstat -an | findstr ":3000" >nul && echo Port 3000 available || echo Port 3000 unavailable
netstat -an | findstr ":3001" >nul && echo Port 3001 available || echo Port 3001 unavailable
netstat -an | findstr ":3002" >nul && echo Port 3002 available || echo Port 3002 unavailable
netstat -an | findstr ":3003" >nul && echo Port 3003 available || echo Port 3003 unavailable
echo.
echo Health check completed
goto end

:backup
echo Data backup...
set BACKUP_DIR=backups
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
copy ".env*" "%BACKUP_DIR%\" >nul 2>&1
echo Configuration files backed up
echo Backup completed, files saved in: %BACKUP_DIR%
goto end

:config
if exist "config-manage.bat" (
    call config-manage.bat %2 %3
) else (
    echo Configuration management script not found
)
goto end

:end
