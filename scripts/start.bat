@echo off
REM VSS Platform 启动脚本 - Nginx 代理方案

echo 🚀 启动 VSS Platform (Nginx 代理方案)
echo ==================================

REM 停止现有容器
echo 停止现有容器...
docker-compose down

REM 构建并启动服务
echo 构建并启动服务...
docker-compose up --build -d

REM 等待服务启动
echo 等待服务启动...
timeout /t 10 /nobreak > nul

REM 检查服务状态
echo 检查服务状态...
docker-compose ps

echo.
echo ✅ VSS Platform 已启动！
echo 🌐 访问地址: http://localhost
echo 📊 API 地址: http://localhost/api
echo 🔍 健康检查: http://localhost/health
echo.
echo 📋 查看日志: docker-compose logs -f
echo 🛑 停止服务: docker-compose down
pause
