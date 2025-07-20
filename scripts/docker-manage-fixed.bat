@echo off
chcp 65001 >nul 2>&1
REM VSS Docker Management Script - Windows Version

REM 切换到项目根目录
cd /d "%~dp0\.."

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="build" goto build
if "%1"=="dev" goto dev
if "%1"=="start" goto start
if "%1"=="proxy" goto proxy
if "%1"=="dev-proxy" goto dev_proxy
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
echo          反向代理架构版本
echo.
echo Usage: docker-manage.bat [command] [params]
echo.
echo Commands:
echo   build [env]  - Build images dev/prod
echo   dev          - Start development environment
echo   start        - Start production environment
echo   proxy        - Start proxy mode 推荐
echo   dev-proxy    - Start development with proxy + hot reload 开发推荐
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
echo   dev   - Development with dev tools, debugging
echo   prod  - Production standard mode
echo   proxy - Production Nginx proxy mode 推荐
echo.
echo 架构说明:
echo   - 使用 Nginx 反向代理统一管理所有服务
echo   - 只对外暴露 80 端口主服务和 8080 端口开发工具
echo   - 前端: 静态文件通过 Nginx 直接服务无端口暴露
echo   - 后端: 内部端口 3000 通过 Nginx /api/ 路由
echo   - 访问地址: http://localhost
echo.
echo Examples:
echo   docker-manage.bat proxy     推荐启动方式
echo   docker-manage.bat build dev
echo   docker-manage.bat logs nginx
echo.
goto end

:build
set BUILD_ENV=%2
if "%BUILD_ENV%"=="" set BUILD_ENV=dev
echo Building %BUILD_ENV% environment images...

if "%BUILD_ENV%"=="dev" (
    docker-compose -f docker-compose.dev-proxy.yml build
) else if "%BUILD_ENV%"=="prod" (
    docker-compose -f docker-compose.yml build
) else (
    echo Error: Invalid environment. Use 'dev' or 'prod'
    goto end
)

echo.
echo Build completed!
goto end

:dev
echo Starting development environment...
echo This mode includes development tools and debugging capabilities

REM 生成开发环境配置
if exist "config-manager.js" (
    node config-manager.js docker dev
    echo Development environment configuration generated
) else (
    echo Warning: config-manager.js not found, using default environment
)

docker-compose -f docker-compose.dev.yml --env-file config\.env.dev up -d

echo.
echo Development environment started!
echo.
echo 访问地址: http://localhost 通过 Nginx 代理
echo 开发工具: http://localhost:8080 Adminer等
echo 邮件测试: http://localhost:8025 Mailhog
echo.
echo 实时日志: docker-compose -f docker-compose.dev.yml logs -f
echo 停止服务: scripts\docker-manage.bat stop
echo.
goto end

:start
echo Starting production environment...
echo This is the standard production deployment mode

REM 生成生产环境配置
if exist "config-manager.js" (
    node config-manager.js docker prod
    echo Production environment configuration generated
) else (
    echo Warning: config-manager.js not found, using default environment
)

docker-compose -f docker-compose.yml --env-file config\.env.prod up -d

echo.
echo Production environment started!
echo.
echo 主访问地址: http://localhost 通过 Nginx 代理
echo.
echo 管理命令:
echo   查看状态: scripts\docker-manage.bat status
echo   查看日志: scripts\docker-manage.bat logs
echo   停止服务: scripts\docker-manage.bat stop
echo.
goto end

:proxy
echo Starting proxy mode recommended...
echo This mode uses Nginx reverse proxy for optimal performance

REM 生成代理环境配置
if exist "config-manager.js" (
    node config-manager.js docker proxy
    echo Proxy environment configuration generated
) else (
    echo Warning: config-manager.js not found, using default environment
)

docker-compose -f docker-compose.proxy.yml --env-file config\.env.proxy up -d

echo.
echo Proxy mode started successfully!
echo.
echo   VSS 代理模式已启动 推荐
echo.
echo   主页面: http://localhost
echo   用户登录: http://localhost/ 
echo   用户注册: http://localhost/ 点击注册
echo.
echo   管理工具:
echo   系统状态: scripts\docker-manage.bat status
echo   Adminer:  http://localhost:8080 数据库管理
echo   Mailhog:  http://localhost:8080 邮件测试
echo.
goto end

:dev_proxy
echo Starting development proxy mode with hot reload...
echo This mode supports React hot updates through nginx proxy

REM 生成开发代理环境配置
if exist "config-manager.js" (
    node config-manager.js docker dev-proxy
    echo Development proxy environment configuration generated
) else (
    echo Warning: config-manager.js not found, using default environment
)

docker-compose -f docker-compose.dev-proxy.yml --env-file config\.env.dev-proxy up -d

echo.
echo Development proxy mode started!
echo   支持 React 热更新的开发环境已启动
echo.
echo   主界面: http://localhost 支持热更新
echo   API调试: http://localhost/api/ 后端接口
echo.
echo   开发工具:
echo   - 前端热更新已启用 代码保存即生效
echo   - 数据库服务 如果启用
echo   - 缓存服务 如果启用
echo   - 调试工具等
echo.
echo   管理命令:
echo   实时日志: scripts\docker-manage.bat logs frontend
echo   重启服务: scripts\docker-manage.bat restart
echo   停止服务: scripts\docker-manage.bat stop
echo.
goto end

:stop
echo Stopping all VSS services...

REM 停止所有可能的docker-compose文件
docker-compose -f docker-compose.yml down 2>nul
docker-compose -f docker-compose.dev.yml down 2>nul
docker-compose -f docker-compose.proxy.yml down 2>nul
docker-compose -f docker-compose.dev-proxy.yml down 2>nul

echo All VSS services stopped.
goto end

:restart
echo Restarting VSS services...

REM 重启当前运行的服务
docker-compose restart

echo Services restarted.
goto end

:status
echo Checking VSS service status...
echo.

docker-compose ps
echo.

echo Active containers:
docker ps --filter "name=vss" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
goto end

:logs
set SERVICE_NAME=%2
echo Showing logs for %SERVICE_NAME%...
echo.

if "%SERVICE_NAME%"=="" (
    docker-compose logs --tail=50 -f
) else (
    docker-compose logs --tail=50 -f %SERVICE_NAME%
)
goto end

:clean
echo Cleaning VSS Docker resources...
echo This will remove stopped containers, unused images, and volumes

set /p CONFIRM="Are you sure? This will remove Docker resources! (y/N): "
if /i "%CONFIRM%"=="y" (
    echo Cleaning up...
    docker-compose down -v --remove-orphans
    docker system prune -f
    docker volume prune -f
    echo Cleanup completed.
) else (
    echo Cleanup cancelled.
)
goto end

:health
echo Performing health check...
echo.

echo Checking Docker daemon...
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker is running
) else (
    echo [ERROR] Docker is not running
    goto end
)

echo.
echo Checking service health...
docker-compose ps
echo.

echo Checking network connectivity...
curl -s -o nul http://localhost
if %errorlevel% equ 0 (
    echo [OK] Main service is accessible
) else (
    echo [WARNING] Main service may not be accessible
)
goto end

:backup
echo Creating VSS data backup...
set BACKUP_DIR=backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_DIR=%BACKUP_DIR: =0%

mkdir backups\%BACKUP_DIR% 2>nul

echo Backing up configuration files...
xcopy config backups\%BACKUP_DIR%\config\ /E /I /Q

echo Backing up Docker volumes...
docker run --rm -v vss_data:/data -v %cd%\backups\%BACKUP_DIR%:/backup alpine tar czf /backup/volumes.tar.gz -C /data .

echo Backup completed: backups\%BACKUP_DIR%
goto end

:config
echo VSS Configuration Management
echo.

if exist "config-manager.js" (
    node config-manager.js %2 %3 %4
) else (
    echo Error: config-manager.js not found
    echo Please ensure you are in the VSS root directory
)
goto end

:end
echo.
echo Script completed.
