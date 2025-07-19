@echo off
REM VSS Port Configuration Viewer

echo.
echo ========================================
echo           VSS Port Configuration
echo ========================================
echo.

if exist "config-manager.js" (
    echo Development Environment:
    echo ----------------------------------------
    node config-manager.js ports dev
    echo.
    echo Production Environment:
    echo ----------------------------------------
    node config-manager.js ports prod
) else (
    echo Default Port Configuration:
    echo ----------------------------------------
    echo Development:
    echo   Frontend: 3001
    echo   Backend: 3003
    echo   Mailhog: 8025
    echo   Adminer: 8081
    echo.
    echo Production:
    echo   Frontend: 3000
    echo   Backend: 3002
    echo ----------------------------------------
)

echo.
echo To modify ports, edit the corresponding .env files:
echo   .env.development  - Development environment
echo   .env.production   - Production environment
echo.
pause
