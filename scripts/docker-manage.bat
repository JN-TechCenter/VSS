@echo off
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
echo   build [env]  - Build images (dev/prod)
echo   dev          - Start development environment
echo   start        - Start production environment
echo   proxy        - Start proxy mode (推荐)
echo   dev-proxy    - Start development with proxy + hot reload (⭐开发推荐⭐)
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
echo   dev   - Development (with dev tools, debugging)
echo   prod  - Production (standard mode)
echo   proxy - Production (Nginx proxy mode) ⭐推荐⭐
echo.
echo 架构说明:
echo   - 使用 Nginx 反向代理统一管理所有服务
echo   - 只对外暴露 80 端口 (主服务) 和 8080 端口 (开发工具)
echo   - 前端: 静态文件，通过 Nginx 直接服务 (无端口暴露)
echo   - 后端: 内部端口 3000 (通过 Nginx /api/ 路由)
echo   - 访问地址: http://localhost
echo.
echo Examples:
echo   docker-manage.bat proxy     (推荐启动方式)
echo   docker-manage.bat build dev
echo   docker-manage.bat logs nginx
echo.
goto end

:build
set BUILD_ENV=%2
if "%BUILD_ENV%"=="" set BUILD_ENV=dev
echo Building %BUILD_ENV% environment images...

REM 生成环境配置
if exist "archive\config-manager.js" (
    node archive\config-manager.js docker %BUILD_ENV%
) else (
    echo Warning: config-manager.js not found, using default environment
)

if "%BUILD_ENV%"=="dev" (
    docker-compose -f docker-compose.dev.yml --env-file config\.env.docker build --no-cache
) else (
    docker-compose -f docker-compose.yml --env-file config\.env.docker build --no-cache
)
echo Image build completed
goto end

:dev
echo Starting development environment...

REM 生成开发环境配置
if exist "archive\config-manager.js" (
    node archive\config-manager.js docker dev
    echo Development environment configuration generated
) else (
    echo Warning: Using default configuration
)

docker-compose -f docker-compose.dev.yml --env-file config\.env.docker up -d
echo Development environment started
echo ============================================
echo   VSS 开发环境已启动
echo ============================================
echo 访问地址: http://localhost (通过 Nginx 代理)
echo 开发工具: http://localhost:8080 (Adminer等)
echo 邮件测试: http://localhost:8025 (Mailhog)
echo ============================================
echo 注意: 前端和后端服务通过 Nginx 代理访问
echo      不直接暴露端口，确保安全性
goto end

:start
echo Starting production environment...

REM 生成生产环境配置
if exist "archive\config-manager.js" (
    node archive\config-manager.js docker prod
    echo Production environment configuration generated
) else (
    echo Warning: Using default configuration
)

docker-compose -f docker-compose.yml --env-file config\.env.docker up -d
echo Production environment started
echo ============================================
echo   VSS 生产环境已启动
echo ============================================
echo 主访问地址: http://localhost (通过 Nginx 代理)
echo ============================================
echo 所有服务通过 Nginx 统一代理访问:
echo   前端应用: http://localhost/
echo   后端API:  http://localhost/api/
echo   WebSocket: http://localhost/ws/
echo ============================================
echo 注意: 采用反向代理架构，只暴露80端口
goto end

:proxy
echo Starting proxy mode (recommended)...

REM 生成代理环境配置
if exist "config-manager.js" (
    node config-manager.js docker proxy
    echo Proxy environment configuration generated
) else (
    echo Warning: Using default configuration
)

docker-compose -f docker-compose.proxy.yml --env-file config\.env.proxy up -d
echo ============================================
echo   VSS 代理模式已启动 (推荐)
echo ============================================
echo 统一访问地址: http://localhost
echo ============================================
echo 服务路由:
echo   网站首页: http://localhost/
echo   用户注册: http://localhost/ (点击注册)
echo   后端API:  http://localhost/api/
echo   WebSocket: http://localhost/ws/
echo   健康检查: http://localhost/health
echo ============================================
echo 开发工具:
echo   Adminer:  http://localhost:8080 (数据库管理)
echo   Mailhog:  http://localhost:8080 (邮件测试)
echo ============================================
echo [✓] 推荐使用此模式进行开发和生产部署
goto end

:stop
echo Stopping all services...
docker-compose -f docker-compose.proxy.yml down 2>nul
docker-compose -f docker-compose.dev.yml down 2>nul
docker-compose -f docker-compose.yml down 2>nul
echo ============================================
echo   所有 VSS 服务已停止
echo ============================================
echo 已停止的服务:
echo   - Nginx 反向代理
echo   - 前端服务
echo   - 后端服务
echo   - 数据库服务 (如果启用)
echo   - 缓存服务 (如果启用)
echo ============================================
goto end

:restart
echo Restarting services...
call :stop
timeout /t 3 /nobreak >nul
echo 启动代理模式服务...
docker-compose -f docker-compose.proxy.yml up -d
echo ============================================
echo   VSS 服务重启完成
echo ============================================
echo 访问地址: http://localhost
echo ============================================
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
    echo [错误] Docker 未运行
    goto end
)
echo [✓] Docker 运行正常
echo.
echo 端口检查:
netstat -an | findstr ":80 " >nul && echo [✓] 端口 80 (Nginx代理) - 已占用 || echo [!] 端口 80 (Nginx代理) - 可用
netstat -an | findstr ":8080 " >nul && echo [✓] 端口 8080 (开发工具) - 已占用 || echo [!] 端口 8080 (开发工具) - 可用
netstat -an | findstr ":5432 " >nul && echo [✓] 端口 5432 (数据库) - 已占用 || echo [!] 端口 5432 (数据库) - 可用
netstat -an | findstr ":6379 " >nul && echo [✓] 端口 6379 (Redis) - 已占用 || echo [!] 端口 6379 (Redis) - 可用
echo.
echo 内部服务端口 (容器间通信):
echo   前端: 静态文件服务 (Nginx 直接服务)
echo   后端: 3000 (通过 nginx /api/ 路由代理)
echo.
echo 容器状态:
docker-compose -f docker-compose.proxy.yml ps 2>nul
echo.
echo [✓] 健康检查完成
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
echo ======= VSS Development Proxy Mode Started =======
echo.
echo 主访问地址: http://localhost (通过 Nginx 代理)
echo 开发工具端口: http://localhost:8080
echo.
echo ✅ 支持特性:
echo   - React 热更新 (HMR)
echo   - WebSocket 连接
echo   - 源代码实时同步
echo   - Nginx 反向代理
echo.
echo 📁 挂载目录:
echo   - 前端源码: ./VSS-frontend/src
echo   - 后端源码: ./VSS-backend/src (如果支持)
echo.
echo 🔄 开发工作流:
echo   1. 修改前端代码即可看到实时更新
echo   2. API 请求通过 /api/ 路由到后端
echo   3. WebSocket 通过 /ws/ 路由到后端
echo.
echo 💡 注意: 这是开发专用模式，包含调试信息
goto end

:end
