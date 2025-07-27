@echo off
echo ========================================
echo    VSS 机器视觉平台 - 服务启动脚本
echo ========================================
echo.

echo [1/3] 启动 AI 推理服务...
start "AI推理服务" cmd /k "cd /d %~dp0inference-server\app && python main.py"
timeout /t 3 /nobreak >nul

echo [2/3] 启动后端服务...
start "后端服务" cmd /k "cd /d %~dp0VSS-backend && .\mvnw.cmd spring-boot:run"
timeout /t 5 /nobreak >nul

echo [3/3] 启动前端服务...
start "前端服务" cmd /k "cd /d %~dp0VSS-frontend && npm run dev"
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo 🚀 所有服务启动完成！
echo ========================================
echo.
echo 📋 服务访问地址:
echo   🌐 前端应用:     http://localhost:3000
echo   🤖 AI推理页面:   http://localhost:3000/ai-inference
echo   ⚙️  后端API:     http://localhost:3002
echo   🔍 AI推理API:    http://localhost:8000
echo.
echo 💡 提示: 请等待所有服务完全启动后再访问
echo    (通常需要 30-60 秒)
echo.
echo 按任意键打开前端应用...
pause >nul
start http://localhost:3000