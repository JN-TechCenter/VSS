@echo off
@REM VSS 反向代理启动脚本 - 解决端口冲突问题
@REM 使用 nginx 统一代理所有服务，只暴露端口 80 和 8080

echo ============================================
echo VSS Vision Platform - 反向代理启动
echo ============================================
echo.

@REM 检查 Docker 是否运行
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未运行，请先启动 Docker Desktop
    pause
    exit /b 1
)

@REM 设置环境变量文件
set ENV_FILE=.env.proxy

echo [信息] 使用配置文件: %ENV_FILE%
echo [信息] 检查配置文件...

if not exist %ENV_FILE% (
    echo [警告] 环境配置文件 %ENV_FILE% 不存在，使用默认配置
    echo [信息] 你可以复制 .env.proxy.example 并修改配置
)

echo.
echo [信息] 启动服务...
echo [信息] 主要访问地址:
echo   - 前端应用: http://localhost
echo   - API 接口: http://localhost/api
echo   - 开发工具: http://localhost:8080
echo.

@REM 停止现有服务
echo [信息] 停止现有服务...
docker-compose -f docker-compose.proxy.yml --env-file %ENV_FILE% down 2>nul

@REM 构建并启动服务
echo [信息] 构建并启动反向代理服务...
docker-compose -f docker-compose.proxy.yml --env-file %ENV_FILE% up --build -d

if %errorlevel% neq 0 (
    echo [错误] 服务启动失败
    pause
    exit /b 1
)

echo.
echo ============================================
echo 🎉 VSS 反向代理服务启动成功!
echo ============================================
echo.
echo 📱 访问地址:
echo   🎨 前端应用:    http://localhost
echo   🔧 API 接口:    http://localhost/api
echo   🛠️  开发工具:    http://localhost:8080
echo   ❤️  健康检查:    http://localhost/health
echo.
echo 📊 服务状态:
docker-compose -f docker-compose.proxy.yml --env-file %ENV_FILE% ps

echo.
echo 💡 管理命令:
echo   查看日志: docker-compose -f docker-compose.proxy.yml logs -f
echo   停止服务: docker-compose -f docker-compose.proxy.yml down
echo   重启服务: docker-compose -f docker-compose.proxy.yml restart
echo.
echo ⚠️  注意: 此配置解决了端口冲突问题，所有服务通过 nginx 统一代理
echo.

@REM 等待服务完全启动
echo [信息] 等待服务完全启动...
timeout /t 5 /nobreak >nul

@REM 检查服务健康状态
echo [信息] 检查服务健康状态...
for /f %%i in ('curl -s -o nul -w "%%{http_code}" http://localhost/health 2^>nul') do set HEALTH_CODE=%%i

if "%HEALTH_CODE%"=="200" (
    echo ✅ 服务健康检查通过
) else (
    echo ⚠️  服务可能还在启动中，请稍等片刻再访问
)

echo.
echo 按任意键退出...
pause >nul
