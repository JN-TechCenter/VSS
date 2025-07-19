@echo off
chcp 65001 >nul 2>&1
echo ============================================
echo VSS Reverse Proxy Solution - Files Overview
echo ============================================
echo.

echo Problem Solution:
echo   Use nginx reverse proxy to manage all service ports
echo   Only expose port 80 (main service) and 8080 (dev tools)
echo   Completely solve port conflict issues
echo.

echo Created Files:
echo.

echo Configuration Files:
if exist "docker-compose.proxy.yml" (
    echo   [OK] docker-compose.proxy.yml     - Reverse proxy Docker config
) else (
    echo   [--] docker-compose.proxy.yml     - Missing
)

if exist ".env.proxy" (
    echo   [OK] .env.proxy                   - Environment variables
) else (
    echo   [--] .env.proxy                   - Missing
)

if exist ".env.proxy.example" (
    echo   [OK] .env.proxy.example           - Configuration example
) else (
    echo   [--] .env.proxy.example           - Missing
)

if exist "nginx-complete.conf" (
    echo   [OK] nginx-complete.conf          - Complete nginx config
) else (
    echo   [--] nginx-complete.conf          - Missing
)

echo.
echo Startup Scripts:
if exist "start-proxy.bat" (
    echo   [OK] start-proxy.bat              - Windows batch startup script
) else (
    echo   [--] start-proxy.bat              - Missing
)

if exist "start-proxy.ps1" (
    echo   [OK] start-proxy.ps1              - PowerShell startup script
) else (
    echo   [--] start-proxy.ps1              - Missing
)

if exist "deploy-proxy.ps1" (
    echo   [OK] deploy-proxy.ps1             - Quick deployment script
) else (
    echo   [--] deploy-proxy.ps1             - Missing
)

echo.
echo Utility Scripts:
if exist "test-proxy.bat" (
    echo   [OK] test-proxy.bat               - Connection test script
) else (
    echo   [--] test-proxy.bat               - Missing
)

echo.
echo Documentation:
if exist "README-PROXY.md" (
    echo   [OK] README-PROXY.md              - Detailed documentation
) else (
    echo   [--] README-PROXY.md              - Missing
)

echo.
echo ============================================
echo Quick Start
echo ============================================
echo.
echo Option 1: One-click deployment (Recommended)
echo   .\deploy-proxy.ps1 -Quick
echo.
echo Option 2: Interactive deployment
echo   .\deploy-proxy.ps1 -Interactive
echo.
echo Option 3: Manual startup
echo   .\start-proxy.bat
echo   or
echo   .\start-proxy.ps1
echo.
echo ============================================
echo Access URLs
echo ============================================
echo.
echo Frontend App:     http://localhost
echo API Endpoints:    http://localhost/api
echo Dev Tools:        http://localhost:8080
echo Health Check:     http://localhost/health
echo.
echo ============================================
echo Management Commands
echo ============================================
echo.
echo Start services:   .\start-proxy.ps1
echo Stop services:    .\start-proxy.ps1 -Stop
echo View logs:        .\start-proxy.ps1 -Logs
echo Restart services: .\start-proxy.ps1 -Restart
echo Test connections: .\test-proxy.bat
echo.
echo ============================================
echo Important Notes
echo ============================================
echo.
echo [OK] Port conflict issues completely resolved
echo [OK] All services unified through nginx proxy
echo [OK] Only requires ports 80 and 8080
echo [OK] Internal service ports not exposed externally
echo [OK] Supports load balancing and cache optimization
echo [OK] Includes security protection and access control
echo.
echo [!] Please change default passwords on first deployment
echo [!] See README-PROXY.md for detailed documentation
echo.
pause
