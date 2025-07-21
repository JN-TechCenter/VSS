@echo off
chcp 65001 >nul 2>&1
REM VSS 项目统一管理脚本

cd /d "%~dp0"

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="status" goto status
if "%1"=="logs" goto logs
if "%1"=="build" goto build
if "%1"=="clean" goto clean
goto help

:help
echo.
echo ========================================
echo     VSS 项目管理工具
echo ========================================
echo.
echo 用法: vss.bat [命令]
echo.
echo 可用命令:
echo   start   - 启动所有服务
echo   stop    - 停止所有服务
echo   status  - 查看服务状态
echo   logs    - 查看日志
echo   build   - 重新构建所有服务
echo   clean   - 清理Docker资源
echo   help    - 显示此帮助信息
echo.
goto end

:start
echo 🚀 启动VSS项目...
docker-compose up -d
echo.
echo ✅ 项目已启动
echo 🌐 访问地址: http://localhost
goto end

:stop
echo 🛑 停止VSS项目...
docker-compose down
echo ✅ 项目已停止
goto end

:status
echo 📊 VSS项目状态:
echo.
docker-compose ps
echo.
echo 🏥 健康检查:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
goto end

:logs
if "%2"=="" (
    echo 📋 查看所有服务日志...
    docker-compose logs -f
) else (
    echo 📋 查看 %2 服务日志...
    docker-compose logs -f %2
)
goto end

:build
echo 🔨 重新构建VSS项目...
docker-compose build --no-cache
echo ✅ 构建完成
goto end

:clean
echo 🧹 清理Docker资源...
docker-compose down -v
docker system prune -f
echo ✅ 清理完成
goto end

:end
