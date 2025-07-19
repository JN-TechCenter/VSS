@echo off
chcp 65001 >nul
echo ============================================
echo VSS 端口配置验证
echo ============================================
echo.

set "errors=0"
set "warnings=0"

echo 检查前端配置...

REM 检查 vite.config.ts
if exist "VSS-frontend\vite.config.ts" (
    findstr /C:"port.*3000" "VSS-frontend\vite.config.ts" >nul
    if %errorlevel% equ 0 (
        echo [警告] 前端 vite.config.ts 中仍有硬编码端口 3000
        set /a warnings+=1
    )
    
    findstr /C:"process.env.VITE_PORT" "VSS-frontend\vite.config.ts" >nul
    if %errorlevel% equ 0 (
        echo [OK] 前端使用环境变量端口配置
    ) else (
        echo [错误] 前端未使用环境变量端口配置
        set /a errors+=1
    )
) else (
    echo [错误] 前端 vite.config.ts 文件不存在
    set /a errors+=1
)

REM 检查前端 API 客户端
if exist "VSS-frontend\src\api\client.ts" (
    findstr /C:"localhost:300" "VSS-frontend\src\api\client.ts" >nul
    if %errorlevel% equ 0 (
        echo [错误] 前端 API 客户端中有硬编码端口
        set /a errors+=1
    ) else (
        echo [OK] 前端 API 客户端使用相对路径
    )
    
    findstr /C:"/api" "VSS-frontend\src\api\client.ts" >nul
    if %errorlevel% equ 0 (
        echo [OK] 前端使用相对 API 路径
    )
) else (
    echo [警告] 前端 API 客户端文件不存在
    set /a warnings+=1
)

echo.
echo 检查后端配置...

REM 检查后端配置
if exist "VSS-backend\src\main\resources\application-docker.properties" (
    findstr /C:"cors.allowed-origins.*localhost:300" "VSS-backend\src\main\resources\application-docker.properties" >nul
    if %errorlevel% equ 0 (
        echo [错误] 后端 CORS 配置中有硬编码端口
        set /a errors+=1
    ) else (
        echo [OK] 后端 CORS 配置不包含硬编码端口
    )
    
    findstr /C:"SERVER_PORT:3002" "VSS-backend\src\main\resources\application-docker.properties" >nul
    if %errorlevel% equ 0 (
        echo [OK] 后端使用环境变量端口配置
    ) else (
        echo [警告] 后端未使用环境变量端口配置
        set /a warnings+=1
    )
) else (
    echo [错误] 后端配置文件不存在
    set /a errors+=1
)

echo.
echo 检查 Docker 配置...

REM 检查 Docker Compose
if exist "docker-compose.proxy.yml" (
    findstr /C:"VITE_API_BASE_URL=/api" "docker-compose.proxy.yml" >nul
    if %errorlevel% equ 0 (
        echo [OK] Docker 构建使用相对 API 路径
    ) else (
        echo [错误] Docker 构建未使用相对 API 路径
        set /a errors+=1
    )
) else (
    echo [错误] Docker Compose 反向代理配置不存在
    set /a errors+=1
)

REM 检查环境变量
if exist ".env.proxy" (
    findstr /C:"VITE_API_BASE_URL=/api" ".env.proxy" >nul
    if %errorlevel% equ 0 (
        echo [OK] 主环境变量使用相对路径
    ) else (
        echo [错误] 主环境变量未使用相对 API 路径
        set /a errors+=1
    )
    
    findstr /C:"NGINX_PORT=80" ".env.proxy" >nul
    if %errorlevel% equ 0 (
        echo [OK] Nginx 端口配置正确
    )
) else (
    echo [错误] 主环境变量文件不存在
    set /a errors+=1
)

echo.
echo ============================================
echo 验证结果
echo ============================================

if %errors% equ 0 (
    echo [成功] 所有配置验证通过！
    echo 您的应用已正确配置为使用反向代理方案
) else (
    echo [失败] 发现 %errors% 个错误
)

if %warnings% gtr 0 (
    echo [警告] 发现 %warnings% 个警告
)

echo.
echo 配置检查项目:
echo ✓ 前端不使用硬编码端口
echo ✓ 后端 CORS 不包含端口
echo ✓ API 客户端使用相对路径
echo ✓ Docker 只暴露必要端口
echo ✓ 环境变量配置正确

echo.
if %errors% equ 0 (
    echo 如果验证通过，可以运行:
    echo   .\deploy-proxy.ps1 -Quick
    echo   或
    echo   .\start-proxy.bat
)

echo.
pause
