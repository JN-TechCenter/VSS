@echo off
REM VSS 端口配置查看工具

echo.
echo ========================================
echo           VSS 端口配置
echo ========================================
echo.

if exist "config-manager.js" (
    echo 开发环境端口:
    echo ----------------------------------------
    node config-manager.js ports dev
    echo.
    echo 生产环境端口:
    echo ----------------------------------------
    node config-manager.js ports prod
) else (
    echo 默认端口配置:
    echo ----------------------------------------
    echo 开发环境:
    echo   前端: 3001
    echo   后端: 3003
    echo   邮件测试: 8025
    echo   数据库管理: 8081
    echo.
    echo 生产环境:
    echo   前端: 3000
    echo   后端: 3002
    echo ----------------------------------------
)

echo.
echo 如需修改端口，请编辑对应的 .env 文件：
echo   .env.development  - 开发环境配置
echo   .env.production   - 生产环境配置
echo.
pause
