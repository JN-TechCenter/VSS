@echo off
title VSS Project Status Update Tool

echo VSS Project Status Update Tool
echo ================================

echo.
echo Checking service status...
echo.

echo Service Status Check:

netstat -an | findstr ":3001 " >nul
if %errorlevel%==0 (
    echo [OK] Frontend Service (Port 3001) - Running
) else (
    echo [NO] Frontend Service (Port 3001) - Not Running
)

netstat -an | findstr ":3002 " >nul
if %errorlevel%==0 (
    echo [OK] Backend Service (Port 3002) - Running
) else (
    echo [NO] Backend Service (Port 3002) - Not Running
)

netstat -an | findstr ":8000 " >nul
if %errorlevel%==0 (
    echo [OK] AI Inference Service (Port 8000) - Running
) else (
    echo [NO] AI Inference Service (Port 8000) - Not Running
)

netstat -an | findstr ":80 " >nul
if %errorlevel%==0 (
    echo [OK] Nginx Proxy (Port 80) - Running
) else (
    echo [NO] Nginx Proxy (Port 80) - Not Running
)

netstat -an | findstr ":5432 " >nul
if %errorlevel%==0 (
    echo [OK] PostgreSQL (Port 5432) - Running
) else (
    echo [NO] PostgreSQL (Port 5432) - Not Running
)

netstat -an | findstr ":6379 " >nul
if %errorlevel%==0 (
    echo [OK] Redis (Port 6379) - Running
) else (
    echo [NO] Redis (Port 6379) - Not Running
)

echo.
echo Update Options:
echo 1. Open Work Plan (WORK_PLAN.md)
echo 2. Open Status Dashboard (PROJECT_STATUS.md)
echo 3. Generate Status Report
echo 4. Quick Start All Services
echo 5. Exit

set /p choice=Please select option (1-5): 

if "%choice%"=="1" (
    echo Opening Work Plan file...
    start notepad WORK_PLAN.md
    goto end
)

if "%choice%"=="2" (
    echo Opening Status Dashboard...
    start notepad PROJECT_STATUS.md
    goto end
)

if "%choice%"=="3" (
    echo Generating Status Report...
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set current_date=%%a-%%b-%%c
    for /f "tokens=1-2 delims=: " %%a in ('time /t') do set current_time=%%a:%%b
    
    echo === VSS Project Status Report === > status_report.txt
    echo Generated: %current_date% %current_time% >> status_report.txt
    echo. >> status_report.txt
    echo Service Status: >> status_report.txt
    
    netstat -an | findstr ":3001 " >nul
    if %errorlevel%==0 (
        echo [OK] Frontend Service (Port 3001) - Running >> status_report.txt
    ) else (
        echo [NO] Frontend Service (Port 3001) - Not Running >> status_report.txt
    )
    
    netstat -an | findstr ":3002 " >nul
    if %errorlevel%==0 (
        echo [OK] Backend Service (Port 3002) - Running >> status_report.txt
    ) else (
        echo [NO] Backend Service (Port 3002) - Not Running >> status_report.txt
    )
    
    netstat -an | findstr ":8000 " >nul
    if %errorlevel%==0 (
        echo [OK] AI Inference Service (Port 8000) - Running >> status_report.txt
    ) else (
        echo [NO] AI Inference Service (Port 8000) - Not Running >> status_report.txt
    )
    
    echo Status report generated: status_report.txt
    start notepad status_report.txt
    goto end
)

if "%choice%"=="4" (
    echo Quick Starting All Services...
    echo Starting Frontend Service...
    start "Frontend Service" cmd /k "cd VSS-frontend && npm run dev"
    timeout /t 2 >nul
    
    echo Starting Backend Service...
    start "Backend Service" cmd /k "cd VSS-backend && .\mvnw.cmd spring-boot:run"
    timeout /t 2 >nul
    
    echo Starting AI Inference Service...
    start "AI Inference Service" cmd /k "cd inference-server\app && python main.py"
    
    echo All services startup commands executed
    goto end
)

if "%choice%"=="5" (
    echo Exiting update tool
    goto end
)

echo Invalid selection

:end
echo.
echo Tip: Remember to update WORK_PLAN.md and PROJECT_STATUS.md regularly
echo Work Plan File: .\WORK_PLAN.md
echo Status Dashboard: .\PROJECT_STATUS.md
echo.
pause