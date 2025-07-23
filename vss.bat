@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

REM VSS 项目统一管理脚本 v2.0
REM 数据持久化版本 - 2025-07-22

cd /d "%~dp0"

if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="restart" goto restart
if "%1"=="status" goto status
if "%1"=="logs" goto logs
if "%1"=="build" goto build
if "%1"=="clean" goto clean
if "%1"=="db" goto db_menu
if "%1"=="backup" goto backup
if "%1"=="restore" goto restore
if "%1"=="volumes" goto volumes
goto help

:help
echo.
echo ========================================
echo     VSS 项目管理工具 v2.0
echo     数据持久化版本
echo ========================================
echo.
echo 用法: vss.bat [命令]
echo.
echo 基础命令:
echo   start     - 启动所有服务（包括数据库）
echo   stop      - 停止所有服务
echo   restart   - 重启所有服务
echo   status    - 查看服务状态
echo   logs      - 查看日志
echo   build     - 重新构建所有服务
echo   clean     - 清理Docker资源
echo.
echo 数据库命令:
echo   db        - 数据库管理菜单
echo   backup    - 备份数据库
echo   restore   - 恢复数据库
echo   volumes   - 查看数据卷信息
echo.
echo 新特性:
echo   ✅ PostgreSQL 15 数据库持久化
echo   ✅ Redis 缓存持久化
echo   ✅ 自动数据备份和恢复
echo   ✅ 完整的服务健康检查
echo.
goto end

:start
echo 🚀 启动VSS项目（数据持久化版本）...
echo.
echo 📊 检查数据卷...
docker volume ls | findstr /C:"vss-postgres-data" >nul
if %errorlevel% neq 0 (
    echo 🔧 创建PostgreSQL数据卷...
    docker volume create vss-postgres-data
)
docker volume ls | findstr /C:"vss-redis-data" >nul
if %errorlevel% neq 0 (
    echo 🔧 创建Redis数据卷...
    docker volume create vss-redis-data
)

echo 🐳 启动服务...
docker-compose up -d --remove-orphans

echo.
echo ⏳ 等待服务启动...
timeout /t 5 /nobreak >nul

echo.
echo 🏥 检查服务健康状态...
docker-compose ps

echo.
echo ✅ 项目已启动！
echo.
echo 🌐 访问地址:
echo   前端:           http://localhost
echo   后端API:        http://localhost:3002/api/v1
echo   YOLO推理:       http://localhost:8084
echo   .NET服务:       http://localhost:8085  
echo   数据分析:       http://localhost:8086
echo   PostgreSQL:     localhost:5432
echo   Redis:          localhost:6379
echo.
echo 📊 数据库信息:
echo   数据库: vss_production_db
echo   用户名: prod_user
echo   Redis密码: 在.env文件中查看
echo.
goto end

:stop
echo 🛑 停止VSS项目...
docker-compose down
echo ✅ 项目已停止（数据已保留）
goto end

:restart
echo 🔄 重启VSS项目...
call :stop
timeout /t 3 /nobreak >nul
call :start
goto end

:status
echo 📊 VSS项目状态（数据持久化版本）:
echo.
echo 🐳 Docker容器状态:
docker-compose ps
echo.
echo 🏥 健康检查详情:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"
echo.
echo 💾 数据卷使用情况:
docker volume ls | findstr /C:"vss-"
echo.
echo 🔍 服务连接测试:
echo 测试数据库连接...
docker-compose exec -T database pg_isready -U prod_user -d vss_production_db 2>nul && echo ✅ PostgreSQL连接正常 || echo ❌ PostgreSQL连接失败
echo 测试Redis连接...
docker-compose exec -T redis redis-cli ping 2>nul && echo ✅ Redis连接正常 || echo ❌ Redis连接失败
goto end

:logs
if "%2"=="" (
    echo 📋 查看所有服务日志...
    docker-compose logs -f --tail=100
) else (
    echo 📋 查看 %2 服务日志...
    docker-compose logs -f --tail=100 %2
)
goto end

:build
echo 🔨 重新构建VSS项目（保留数据）...
echo.
echo ⚠️  构建过程中将保留所有数据
echo.
docker-compose build --no-cache --parallel
echo ✅ 构建完成
goto end

:clean
echo.
echo ⚠️  警告：此操作将删除所有数据！
echo.
set /p confirm="确认要清理所有数据吗？(y/N): "
if /i "%confirm%"=="y" (
    echo 🧹 清理Docker资源和数据...
    docker-compose down -v --remove-orphans
    docker system prune -af --volumes
    echo ✅ 清理完成（所有数据已删除）
) else (
    echo ❌ 清理操作已取消
)
goto end

:db_menu
echo.
echo ========================================
echo        数据库管理菜单
echo ========================================
echo.
echo 1. 连接到PostgreSQL数据库
echo 2. 查看数据库信息
echo 3. 备份数据库
echo 4. 恢复数据库
echo 5. 重置数据库
echo 6. 查看Redis信息
echo 7. 清理Redis缓存
echo 8. 返回主菜单
echo.
set /p choice="请选择操作 (1-8): "

if "%choice%"=="1" goto db_connect
if "%choice%"=="2" goto db_info
if "%choice%"=="3" goto backup
if "%choice%"=="4" goto restore
if "%choice%"=="5" goto db_reset
if "%choice%"=="6" goto redis_info
if "%choice%"=="7" goto redis_clean
if "%choice%"=="8" goto end
echo ❌ 无效选择
goto db_menu

:db_connect
echo 🔗 连接到PostgreSQL数据库...
echo 数据库: vss_production_db
echo 用户: prod_user
echo.
docker-compose exec database psql -U prod_user -d vss_production_db
goto end

:db_info
echo 📊 数据库信息:
echo.
docker-compose exec database psql -U prod_user -d vss_production_db -c "\l"
echo.
echo 📋 表信息:
docker-compose exec database psql -U prod_user -d vss_production_db -c "\dt"
echo.
echo 📈 数据库大小:
docker-compose exec database psql -U prod_user -d vss_production_db -c "SELECT pg_size_pretty(pg_database_size('vss_production_db')) as size;"
goto end

:backup
echo 💾 备份数据库...
set backup_file=backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql
set backup_file=%backup_file: =0%
echo 备份文件: %backup_file%
docker-compose exec database pg_dump -U prod_user -d vss_production_db > backups\%backup_file%
if %errorlevel% equ 0 (
    echo ✅ 数据库备份完成: backups\%backup_file%
) else (
    echo ❌ 备份失败
)
goto end

:restore
echo 🔄 恢复数据库...
dir /b backups\*.sql 2>nul
if %errorlevel% neq 0 (
    echo ❌ 没有找到备份文件
    goto end
)
echo.
set /p backup_file="请输入备份文件名: "
if exist "backups\%backup_file%" (
    echo 恢复备份: %backup_file%
    docker-compose exec -T database psql -U prod_user -d vss_production_db < backups\%backup_file%
    echo ✅ 数据库恢复完成
) else (
    echo ❌ 备份文件不存在
)
goto end

:db_reset
echo.
echo ⚠️  警告：此操作将重置数据库！
echo.
set /p confirm="确认要重置数据库吗？(y/N): "
if /i "%confirm%"=="y" (
    echo 🔄 重置数据库...
    docker-compose exec database psql -U prod_user -d vss_production_db -f /docker-entrypoint-initdb.d/01-init-database.sql
    echo ✅ 数据库重置完成
) else (
    echo ❌ 重置操作已取消
)
goto end

:redis_info
echo 📊 Redis信息:
docker-compose exec redis redis-cli info server
echo.
echo 💾 内存使用:
docker-compose exec redis redis-cli info memory
echo.
echo 🔑 键统计:
docker-compose exec redis redis-cli info keyspace
goto end

:redis_clean
echo.
echo ⚠️  警告：此操作将清空Redis缓存！
echo.
set /p confirm="确认要清空Redis缓存吗？(y/N): "
if /i "%confirm%"=="y" (
    echo 🧹 清空Redis缓存...
    docker-compose exec redis redis-cli FLUSHALL
    echo ✅ Redis缓存已清空
) else (
    echo ❌ 清空操作已取消
)
goto end

:volumes
echo 💾 VSS数据卷信息:
echo.
echo 📊 数据卷列表:
docker volume ls | findstr /C:"vss-"
echo.
echo 📈 数据卷详细信息:
for /f "tokens=*" %%i in ('docker volume ls -q ^| findstr /C:"vss-"') do (
    echo.
    echo 卷名: %%i
    docker volume inspect %%i --format "  路径: {{.Mountpoint}}"
    docker volume inspect %%i --format "  创建时间: {{.CreatedAt}}"
    echo.
)
goto end

:end
