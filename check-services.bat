@echo off
chcp 65001 >nul
echo ========================================
echo VSS 视觉监控平台 - 服务健康检查
echo ========================================

echo.
echo 📊 检查端口占用情况...
echo ----------------------------------------
netstat -an | findstr ":3001 " >nul && echo ✅ 端口 3001 已占用 (前端服务) || echo ❌ 端口 3001 空闲
netstat -an | findstr ":3002 " >nul && echo ✅ 端口 3002 已占用 (后端服务) || echo ❌ 端口 3002 空闲
netstat -an | findstr ":8001 " >nul && echo ✅ 端口 8001 已占用 (AI推理服务) || echo ❌ 端口 8001 空闲

echo.
echo 🔗 快速访问链接:
echo ----------------------------------------
echo 前端应用:     http://localhost:3001
echo AI推理页面:   http://localhost:3001/ai-inference
echo 后端健康检查: http://localhost:3002/actuator/health
echo AI服务健康:   http://localhost:8001/health
echo AI模型列表:   http://localhost:8001/models

echo.
echo 💡 提示: 请在浏览器中访问上述链接验证服务状态
echo ✅ 健康检查完成！
pause