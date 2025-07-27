@echo off
echo ========================================
echo VSS 视觉监控平台 - 开发环境启动脚本
echo ========================================

echo.
echo 🚀 启动开发环境服务...

echo.
echo 📊 启动AI推理服务 (端口 8001)...
cd /d "d:\VSS\inference-server"
start "AI推理服务" cmd /k "python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload"

echo.
echo ⏳ 等待AI服务启动...
timeout /t 5 /nobreak >nul

echo.
echo 🔧 启动后端服务 (端口 3002)...
cd /d "d:\VSS\VSS-backend"
start "后端服务" cmd /k ".\mvnw.cmd spring-boot:run"

echo.
echo ⏳ 等待后端服务启动...
timeout /t 10 /nobreak >nul

echo.
echo 🎨 启动前端服务 (端口 3001)...
cd /d "d:\VSS\VSS-frontend"
start "前端服务" cmd /k "npm run dev"

echo.
echo ⏳ 等待前端服务启动...
timeout /t 10 /nobreak >nul

echo.
echo 🌐 服务访问地址:
echo ========================================
echo 🎨 前端应用:     http://localhost:3001
echo 🔧 后端API:      http://localhost:3002
echo 🤖 AI推理服务:   http://localhost:8001
echo 📊 AI推理页面:   http://localhost:3001/ai-inference
echo ========================================

echo.
echo ✅ 开发环境启动完成！
echo 💡 提示: 所有服务将在新的命令行窗口中运行
echo 💡 关闭对应窗口即可停止相应服务

cd /d "d:\VSS"
pause