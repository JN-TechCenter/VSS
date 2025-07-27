@echo off
echo ========================================
echo VSS 视觉监控平台 - Docker 部署脚本
echo ========================================

echo.
echo 🔍 检查 Docker 环境...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker 未安装或未启动，请先安装并启动 Docker Desktop
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose 未安装，请先安装 Docker Compose
    pause
    exit /b 1
)

echo ✅ Docker 环境检查通过

echo.
echo 🛑 停止现有容器...
docker-compose down

echo.
echo 🧹 清理旧镜像和容器...
docker system prune -f

echo.
echo 🏗️ 构建并启动服务...
docker-compose up --build -d

echo.
echo ⏳ 等待服务启动...
timeout /t 30 /nobreak >nul

echo.
echo 🔍 检查服务状态...
docker-compose ps

echo.
echo 🌐 服务访问地址:
echo ========================================
echo 🎨 前端应用:     http://localhost
echo 🔧 API服务:      http://localhost/api
echo 🤖 AI推理服务:   http://localhost/ai
echo 📊 开发工具:     http://localhost:8080
echo 🗄️ 数据库:       localhost:5432
echo 📝 Redis:        localhost:6379
echo ========================================

echo.
echo 📋 常用命令:
echo - 查看日志: docker-compose logs -f [service_name]
echo - 停止服务: docker-compose down
echo - 重启服务: docker-compose restart [service_name]
echo - 进入容器: docker-compose exec [service_name] bash

echo.
echo ✅ 部署完成！
echo 💡 提示: 首次启动可能需要几分钟时间下载模型文件
pause