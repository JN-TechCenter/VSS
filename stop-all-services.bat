@echo off
echo ========================================
echo    VSS 机器视觉平台 - 服务停止脚本
echo ========================================
echo.

echo 正在停止所有VSS相关服务...
echo.

echo [1/4] 停止前端服务 (端口 3000)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
    echo 终止进程 %%a
    taskkill /PID %%a /F >nul 2>&1
)

echo [2/4] 停止后端服务 (端口 3002)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3002') do (
    echo 终止进程 %%a
    taskkill /PID %%a /F >nul 2>&1
)

echo [3/4] 停止AI推理服务 (端口 8000)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000') do (
    echo 终止进程 %%a
    taskkill /PID %%a /F >nul 2>&1
)

echo [4/4] 清理相关进程...
taskkill /IM "node.exe" /F >nul 2>&1
taskkill /IM "java.exe" /F >nul 2>&1
taskkill /IM "python.exe" /F >nul 2>&1

echo.
echo ========================================
echo ✅ 所有服务已停止
echo ========================================
echo.
pause