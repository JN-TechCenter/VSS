@echo off
echo ============================================
echo VSS 反向代理解决方案 - 文件总览
echo ============================================
echo.

echo 🎯 问题解决方案：
echo   使用 nginx 反向代理统一管理所有服务端口
echo   只暴露端口 80 (主服务) 和 8080 (开发工具)
echo   完全解决端口冲突问题
echo.

echo 📁 新创建的文件：
echo.

echo 📋 配置文件：
if exist "docker-compose.proxy.yml" (
    echo   ✅ docker-compose.proxy.yml     - 反向代理 Docker 配置
) else (
    echo   ❌ docker-compose.proxy.yml     - 缺失
)

if exist ".env.proxy" (
    echo   ✅ .env.proxy                   - 环境变量配置
) else (
    echo   ❌ .env.proxy                   - 缺失
)

if exist ".env.proxy.example" (
    echo   ✅ .env.proxy.example           - 配置文件示例
) else (
    echo   ❌ .env.proxy.example           - 缺失
)

if exist "nginx-complete.conf" (
    echo   ✅ nginx-complete.conf          - 完整 nginx 配置
) else (
    echo   ❌ nginx-complete.conf          - 缺失
)

echo.
echo 🚀 启动脚本：
if exist "start-proxy.bat" (
    echo   ✅ start-proxy.bat              - Windows 批处理启动脚本
) else (
    echo   ❌ start-proxy.bat              - 缺失
)

if exist "start-proxy.ps1" (
    echo   ✅ start-proxy.ps1              - PowerShell 启动脚本
) else (
    echo   ❌ start-proxy.ps1              - 缺失
)

if exist "deploy-proxy.ps1" (
    echo   ✅ deploy-proxy.ps1             - 快速部署脚本
) else (
    echo   ❌ deploy-proxy.ps1             - 缺失
)

echo.
echo 🔧 工具脚本：
if exist "test-proxy.bat" (
    echo   ✅ test-proxy.bat               - 连接测试脚本
) else (
    echo   ❌ test-proxy.bat               - 缺失
)

echo.
echo 📖 文档：
if exist "README-PROXY.md" (
    echo   ✅ README-PROXY.md              - 详细说明文档
) else (
    echo   ❌ README-PROXY.md              - 缺失
)

echo.
echo ============================================
echo 🚀 快速开始
echo ============================================
echo.
echo 方式一：一键部署（推荐）
echo   .\deploy-proxy.ps1 -Quick
echo.
echo 方式二：交互式部署
echo   .\deploy-proxy.ps1 -Interactive
echo.
echo 方式三：手动启动
echo   .\start-proxy.bat
echo   或
echo   .\start-proxy.ps1
echo.
echo ============================================
echo 📊 访问地址
echo ============================================
echo.
echo 🎨 前端应用:      http://localhost
echo 🔧 API 接口:      http://localhost/api
echo 🛠️  开发工具:      http://localhost:8080
echo ❤️  健康检查:      http://localhost/health
echo.
echo ============================================
echo 💡 管理命令
echo ============================================
echo.
echo 启动服务:    .\start-proxy.ps1
echo 停止服务:    .\start-proxy.ps1 -Stop
echo 查看日志:    .\start-proxy.ps1 -Logs
echo 重启服务:    .\start-proxy.ps1 -Restart
echo 连接测试:    .\test-proxy.bat
echo.
echo ============================================
echo ⚠️  重要提示
echo ============================================
echo.
echo ✅ 端口冲突问题已完全解决
echo ✅ 所有服务通过 nginx 统一代理
echo ✅ 只需要端口 80 和 8080
echo ✅ 内部服务端口不对外暴露
echo ✅ 支持负载均衡和缓存优化
echo ✅ 包含安全防护和访问控制
echo.
echo 🔒 首次部署请修改默认密码
echo 📝 详细文档请查看 README-PROXY.md
echo.
pause
