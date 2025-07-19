@echo off
REM VSS Docker 管理脚本 - Windows 版本

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
echo ======= VSS Docker 管理工具 =======
echo.
echo 用法: docker-manage.bat [命令] [参数]
echo.
echo 命令:
echo   build [env]  - 构建镜像 (dev/prod)
echo   dev          - 启动开发环境
echo   start        - 启动生产环境
echo   stop         - 停止所有服务
echo   restart      - 重启服务
echo   status       - 查看服务状态
echo   logs [svc]   - 查看日志
echo   clean        - 清理资源
echo   health       - 健康检查
echo   backup       - 数据备份
echo   config       - 配置管理
echo   help         - 显示帮助
echo.
echo 环境:
echo   dev   - 开发环境 (热重载, 调试)
echo   prod  - 生产环境 (优化, 稳定)
echo.
echo 示例:
echo   docker-manage.bat build dev
echo   docker-manage.bat dev
echo   docker-manage.bat logs frontend
echo.
goto end

:build
set BUILD_ENV=%2
if "%BUILD_ENV%"=="" set BUILD_ENV=dev
echo 构建 %BUILD_ENV% 环境镜像...
if "%BUILD_ENV%"=="dev" (
    docker-compose -f docker-compose.dev.yml build --no-cache
) else (
    docker-compose -f docker-compose.yml build --no-cache
)
echo 镜像构建完成
goto end

:dev
echo 启动开发环境...
docker-compose -f docker-compose.dev.yml up -d
echo 开发环境启动完成
echo 前端: http://localhost:3001
echo 后端: http://localhost:3003
goto end

:start
echo 启动生产环境...
docker-compose up -d
echo 生产环境启动完成
echo 前端: http://localhost:3000
echo 后端: http://localhost:3002
goto end

:stop
echo 停止所有服务...
docker-compose -f docker-compose.dev.yml down
docker-compose down
echo 服务已停止
goto end

:restart
echo 重启服务...
call :stop
timeout /t 3 /nobreak >nul
docker-compose up -d
echo 服务重启完成
goto end

:status
echo 服务状态:
docker-compose ps
echo.
echo 存储使用:
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
echo 清理 Docker 资源...
echo.
echo 请选择清理级别:
echo 1) 轻度清理 (停止的容器)
echo 2) 中度清理 (+ 未使用的镜像)
echo 3) 深度清理 (+ 所有未使用的数据)
echo.
set /p clean_level=请选择 (1-3): 

if "%clean_level%"=="1" (
    docker container prune -f
    docker network prune -f
    echo 轻度清理完成
) else if "%clean_level%"=="2" (
    docker container prune -f
    docker network prune -f
    docker image prune -f
    echo 中度清理完成
) else if "%clean_level%"=="3" (
    docker system prune -a -f --volumes
    echo 深度清理完成
) else (
    echo 无效选择
)
goto end

:health
echo 系统健康检查...
echo.
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker 未运行
    goto end
)
echo Docker 运行正常
echo.
echo 端口检查:
netstat -an | findstr ":3000" >nul && echo 端口 3000 可用 || echo 端口 3000 不可用
netstat -an | findstr ":3001" >nul && echo 端口 3001 可用 || echo 端口 3001 不可用
netstat -an | findstr ":3002" >nul && echo 端口 3002 可用 || echo 端口 3002 不可用
netstat -an | findstr ":3003" >nul && echo 端口 3003 可用 || echo 端口 3003 不可用
echo.
echo 健康检查完成
goto end

:backup
echo 数据备份...
set BACKUP_DIR=backups
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
copy ".env*" "%BACKUP_DIR%\" >nul 2>&1
echo 配置文件已备份
echo 备份完成，文件保存在: %BACKUP_DIR%
goto end

:config
if exist "config-manage.bat" (
    call config-manage.bat %2 %3
) else (
    echo 配置管理脚本不存在
)
goto end

:end
