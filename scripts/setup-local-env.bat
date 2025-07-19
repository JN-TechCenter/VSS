@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: VSS 简化版本地环境配置脚本
:: 适用于已安装基础工具的环境

echo.
echo ========================================
echo   VSS 本地环境快速配置
echo ========================================
echo.
echo 此脚本将配置已安装的开发工具：
echo [1] 检查必要工具是否已安装
echo [2] 安装项目依赖
echo [3] 创建启动脚本
echo [4] 配置 Nginx 代理
echo.

set "PROJECT_PATH=%~dp0"

:: 检查必要工具
echo [检查] Node.js...
node --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [错误] 未检测到 Node.js，请先安装 Node.js
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do echo [✓] Node.js !%%i!
)

echo [检查] Java...
java -version >nul 2>&1
if !errorlevel! neq 0 (
    echo [错误] 未检测到 Java，请先安装 JDK 17+
    echo 下载地址: https://adoptium.net/
    pause
    exit /b 1
) else (
    echo [✓] Java 已安装
)

echo [检查] Maven...
mvn --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [警告] 未检测到 Maven，将使用项目内置的 mvnw
) else (
    echo [✓] Maven 已安装
)

:: 安装前端依赖
echo.
echo [配置] 安装前端依赖...
cd "%PROJECT_PATH%VSS-frontend"
if exist "package.json" (
    npm install
    if !errorlevel! equ 0 (
        echo [✓] 前端依赖安装成功
    ) else (
        echo [!] 前端依赖安装可能有问题
    )
) else (
    echo [错误] 未找到 package.json
)

:: 检查后端配置
echo.
echo [配置] 检查后端配置...
cd "%PROJECT_PATH%VSS-backend"
if exist "pom.xml" (
    echo [✓] 后端配置正常
) else (
    echo [错误] 未找到 pom.xml
)

:: 配置 Nginx (如果存在)
echo.
echo [配置] 检查 Nginx...
where nginx >nul 2>&1
if !errorlevel! equ 0 (
    echo [✓] 系统已安装 Nginx
    set "NGINX_INSTALLED=1"
) else (
    if exist "D:\nginx\nginx-1.24.0\nginx.exe" (
        echo [✓] 发现本地 Nginx: D:\nginx\nginx-1.24.0\
        set "NGINX_PATH=D:\nginx\nginx-1.24.0"
        set "NGINX_INSTALLED=1"
    ) else (
        echo [!] 未发现 Nginx，将创建无代理启动脚本
        set "NGINX_INSTALLED=0"
    )
)

:: 创建启动脚本
echo.
echo [配置] 创建启动脚本...
cd "%PROJECT_PATH%"

:: 前端启动脚本
echo @echo off > start-frontend.bat
echo title VSS Frontend Server >> start-frontend.bat
echo cd "VSS-frontend" >> start-frontend.bat
echo echo ======================================== >> start-frontend.bat
echo echo   VSS 前端开发服务器 >> start-frontend.bat
echo echo ======================================== >> start-frontend.bat
echo echo 启动中... >> start-frontend.bat
echo npm run dev >> start-frontend.bat
echo pause >> start-frontend.bat

:: 后端启动脚本
echo @echo off > start-backend.bat
echo title VSS Backend Server >> start-backend.bat
echo cd "VSS-backend" >> start-backend.bat
echo echo ======================================== >> start-backend.bat
echo echo   VSS 后端开发服务器 >> start-backend.bat
echo echo ======================================== >> start-backend.bat
echo echo 启动中... >> start-backend.bat
echo .\mvnw.cmd spring-boot:run >> start-backend.bat
echo pause >> start-backend.bat

:: Nginx 启动脚本 (如果可用)
if !NGINX_INSTALLED! equ 1 (
    if defined NGINX_PATH (
        echo @echo off > start-nginx.bat
        echo title VSS Nginx Proxy >> start-nginx.bat
        echo cd /d "%NGINX_PATH%" >> start-nginx.bat
    ) else (
        echo @echo off > start-nginx.bat
        echo title VSS Nginx Proxy >> start-nginx.bat
    )
    echo echo ======================================== >> start-nginx.bat
    echo echo   VSS Nginx 反向代理 >> start-nginx.bat
    echo echo ======================================== >> start-nginx.bat
    echo echo 启动 Nginx... >> start-nginx.bat
    echo start "" nginx.exe >> start-nginx.bat
    echo echo. >> start-nginx.bat
    echo echo Nginx 已启动！ >> start-nginx.bat
    echo echo 代理地址: http://localhost:8080 >> start-nginx.bat
    echo echo. >> start-nginx.bat
    echo echo 按任意键停止 Nginx... >> start-nginx.bat
    echo pause ^>nul >> start-nginx.bat
    echo nginx.exe -s quit >> start-nginx.bat
    echo echo Nginx 已停止 >> start-nginx.bat
    echo pause >> start-nginx.bat
)

:: 一键启动脚本
echo @echo off > start-all.bat
echo title VSS Development Environment >> start-all.bat
echo setlocal enabledelayedexpansion >> start-all.bat
echo echo. >> start-all.bat
echo echo ======================================== >> start-all.bat
echo echo   VSS 开发环境一键启动 >> start-all.bat
echo echo ======================================== >> start-all.bat
echo echo. >> start-all.bat
echo echo 正在启动所有服务... >> start-all.bat
echo echo. >> start-all.bat

echo echo [1/3] 启动后端服务器... >> start-all.bat
echo start "VSS-Backend" cmd /k "call start-backend.bat" >> start-all.bat
echo timeout /t 5 /nobreak ^>nul >> start-all.bat

echo echo [2/3] 启动前端服务器... >> start-all.bat  
echo start "VSS-Frontend" cmd /k "call start-frontend.bat" >> start-all.bat
echo timeout /t 3 /nobreak ^>nul >> start-all.bat

if !NGINX_INSTALLED! equ 1 (
    echo echo [3/3] 启动 Nginx 代理... >> start-all.bat
    echo start "VSS-Nginx" cmd /k "call start-nginx.bat" >> start-all.bat
    echo echo. >> start-all.bat
    echo echo 所有服务启动完成！ >> start-all.bat
    echo echo. >> start-all.bat
    echo echo 访问地址: >> start-all.bat
    echo echo   代理访问: http://localhost:8080 ^(推荐^) >> start-all.bat
    echo echo   前端直连: http://localhost:3000 >> start-all.bat
    echo echo   后端API:  http://localhost:3000 >> start-all.bat
) else (
    echo echo [3/3] Nginx 未安装，跳过代理启动 >> start-all.bat
    echo echo. >> start-all.bat
    echo echo 前端和后端服务启动完成！ >> start-all.bat
    echo echo. >> start-all.bat
    echo echo 访问地址: >> start-all.bat
    echo echo   前端访问: http://localhost:3000 >> start-all.bat
    echo echo   后端API:  http://localhost:3000 >> start-all.bat
    echo echo. >> start-all.bat
    echo echo 建议安装 Nginx 以获得更好的开发体验 >> start-all.bat
)

echo echo. >> start-all.bat
echo echo 按任意键关闭此窗口... >> start-all.bat
echo pause ^>nul >> start-all.bat

:: 停止所有服务脚本
echo @echo off > stop-all.bat
echo title Stop VSS Services >> stop-all.bat
echo echo 正在停止 VSS 服务... >> stop-all.bat
echo taskkill /f /im "node.exe" 2^>nul >> stop-all.bat
echo taskkill /f /im "java.exe" 2^>nul >> stop-all.bat
if !NGINX_INSTALLED! equ 1 (
    if defined NGINX_PATH (
        echo cd /d "%NGINX_PATH%" >> stop-all.bat
    )
    echo nginx.exe -s quit 2^>nul >> stop-all.bat
)
echo echo 所有服务已停止 >> stop-all.bat
echo pause >> stop-all.bat

:: 创建开发指南
echo @echo off > dev-guide.bat
echo title VSS 开发指南 >> dev-guide.bat
echo echo. >> dev-guide.bat
echo echo ======================================== >> dev-guide.bat
echo echo   VSS 开发环境使用指南 >> dev-guide.bat
echo echo ======================================== >> dev-guide.bat
echo echo. >> dev-guide.bat
echo echo 启动服务: >> dev-guide.bat
echo echo   start-all.bat      - 一键启动所有服务 >> dev-guide.bat
echo echo   start-frontend.bat - 只启动前端 >> dev-guide.bat
echo echo   start-backend.bat  - 只启动后端 >> dev-guide.bat
if !NGINX_INSTALLED! equ 1 (
    echo echo   start-nginx.bat    - 只启动 Nginx >> dev-guide.bat
)
echo echo. >> dev-guide.bat
echo echo 停止服务: >> dev-guide.bat
echo echo   stop-all.bat       - 停止所有服务 >> dev-guide.bat
echo echo. >> dev-guide.bat
echo echo 访问地址: >> dev-guide.bat
if !NGINX_INSTALLED! equ 1 (
    echo echo   http://localhost:8080 - 代理访问 ^(推荐^) >> dev-guide.bat
)
echo echo   http://localhost:3000 - 前端直连 >> dev-guide.bat
echo echo   http://localhost:3000 - 后端API >> dev-guide.bat
echo echo. >> dev-guide.bat
echo echo 开发说明: >> dev-guide.bat
echo echo   - 前端代码修改会自动热重载 >> dev-guide.bat
echo echo   - 后端代码修改需要重启服务 >> dev-guide.bat
echo echo   - 端口冲突时请检查是否有其他程序占用 >> dev-guide.bat
echo echo. >> dev-guide.bat
echo pause >> dev-guide.bat

echo [✓] 启动脚本创建完成

:: 完成配置
echo.
echo ========================================
echo   配置完成！
echo ========================================
echo.
echo 已创建以下脚本：
echo   start-all.bat      - 一键启动所有服务
echo   start-frontend.bat - 启动前端服务器
echo   start-backend.bat  - 启动后端服务器
if !NGINX_INSTALLED! equ 1 (
    echo   start-nginx.bat    - 启动 Nginx 代理
)
echo   stop-all.bat       - 停止所有服务
echo   dev-guide.bat      - 查看开发指南
echo.
echo 使用方法：
echo   1. 双击 'start-all.bat' 启动所有服务
if !NGINX_INSTALLED! equ 1 (
    echo   2. 访问 http://localhost:8080 查看应用
) else (
    echo   2. 访问 http://localhost:3000 查看应用
)
echo   3. 双击 'dev-guide.bat' 查看详细指南
echo.
echo 按任意键退出...
pause >nul
