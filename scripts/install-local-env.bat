@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: VSS 本地开发环境自动安装脚本
:: 支持一键安装所有必要的开发工具和依赖

REM 切换到项目根目录
cd /d "%~dp0\.."

echo.
echo ========================================
echo   VSS 本地开发环境自动安装程序
echo ========================================
echo.
echo 此脚本将自动安装以下组件：
echo [1] Node.js (前端开发环境)
echo [2] Java JDK (后端开发环境) 
echo [3] Maven (后端构建工具)
echo [4] Nginx (本地反向代理)
echo [5] Git (版本控制)
echo [6] 项目依赖包
echo.
echo 按任意键开始安装，或按 Ctrl+C 取消...
pause >nul

:: 设置安装路径
set "INSTALL_ROOT=D:\VSS-DevTools"
set "NODE_PATH=%INSTALL_ROOT%\nodejs"
set "JAVA_PATH=%INSTALL_ROOT%\java"
set "MAVEN_PATH=%INSTALL_ROOT%\maven"
set "NGINX_PATH=%INSTALL_ROOT%\nginx"
set "PROJECT_PATH=%~dp0"

echo.
echo [信息] 创建安装目录: %INSTALL_ROOT%
mkdir "%INSTALL_ROOT%" 2>nul
mkdir "%NODE_PATH%" 2>nul
mkdir "%JAVA_PATH%" 2>nul
mkdir "%MAVEN_PATH%" 2>nul

:: ===========================================
:: 检查并安装 Chocolatey (包管理器)
:: ===========================================
echo.
echo [步骤 1/7] 检查包管理器 Chocolatey...
choco version >nul 2>&1
if !errorlevel! neq 0 (
    echo [安装] 正在安装 Chocolatey 包管理器...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if !errorlevel! neq 0 (
        echo [错误] Chocolatey 安装失败，将使用手动安装方式
        goto :manual_install
    )
    echo [完成] Chocolatey 安装成功
) else (
    echo [跳过] Chocolatey 已安装
)

:: ===========================================
:: 安装 Node.js
:: ===========================================
echo.
echo [步骤 2/7] 检查并安装 Node.js...
node --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [安装] 正在安装 Node.js LTS...
    choco install nodejs-lts -y
    if !errorlevel! neq 0 (
        echo [错误] Node.js 安装失败
        goto :manual_nodejs
    )
    echo [完成] Node.js 安装成功
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [跳过] Node.js 已安装，版本: !NODE_VERSION!
)

:: ===========================================
:: 安装 Java JDK
:: ===========================================
echo.
echo [步骤 3/7] 检查并安装 Java JDK...
java -version >nul 2>&1
if !errorlevel! neq 0 (
    echo [安装] 正在安装 OpenJDK 17...
    choco install openjdk17 -y
    if !errorlevel! neq 0 (
        echo [错误] Java JDK 安装失败
        goto :manual_java
    )
    echo [完成] Java JDK 安装成功
) else (
    echo [跳过] Java 已安装
    java -version
)

:: ===========================================
:: 安装 Maven
:: ===========================================
echo.
echo [步骤 4/7] 检查并安装 Maven...
mvn --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [安装] 正在安装 Apache Maven...
    choco install maven -y
    if !errorlevel! neq 0 (
        echo [错误] Maven 安装失败
        goto :manual_maven
    )
    echo [完成] Maven 安装成功
) else (
    echo [跳过] Maven 已安装
    mvn --version | findstr "Apache Maven"
)

:: ===========================================
:: 安装本地 Nginx
:: ===========================================
echo.
echo [步骤 5/7] 安装本地 Nginx...
if exist "%NGINX_PATH%\nginx.exe" (
    echo [跳过] Nginx 已安装在: %NGINX_PATH%
) else (
    echo [安装] 正在下载并安装 Nginx...
    
    :: 下载 Nginx
    powershell -Command "Invoke-WebRequest -Uri 'http://nginx.org/download/nginx-1.24.0.zip' -OutFile '%INSTALL_ROOT%\nginx.zip'"
    if !errorlevel! neq 0 (
        echo [错误] Nginx 下载失败
        goto :manual_nginx
    )
    
    :: 解压 Nginx
    powershell -Command "Expand-Archive -Path '%INSTALL_ROOT%\nginx.zip' -DestinationPath '%INSTALL_ROOT%' -Force"
    move "%INSTALL_ROOT%\nginx-1.24.0" "%NGINX_PATH%" >nul 2>&1
    del "%INSTALL_ROOT%\nginx.zip" >nul 2>&1
    
    :: 复制项目配置
    copy "%PROJECT_PATH%nginx\nginx-local.conf" "%NGINX_PATH%\conf\nginx.conf" >nul 2>&1
    
    echo [完成] Nginx 安装成功: %NGINX_PATH%
)

:: ===========================================
:: 安装 Git (如果未安装)
:: ===========================================
echo.
echo [步骤 6/7] 检查并安装 Git...
git --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [安装] 正在安装 Git...
    choco install git -y
    if !errorlevel! neq 0 (
        echo [错误] Git 安装失败
        goto :manual_git
    )
    echo [完成] Git 安装成功
) else (
    echo [跳过] Git 已安装
    git --version
)

:: ===========================================
:: 安装项目依赖
:: ===========================================
echo.
echo [步骤 7/7] 安装项目依赖...

:: 前端依赖
echo [安装] 正在安装前端依赖...
cd "%PROJECT_PATH%VSS-frontend"
if exist "package.json" (
    npm install
    if !errorlevel! neq 0 (
        echo [警告] 前端依赖安装可能有问题，请手动检查
    ) else (
        echo [完成] 前端依赖安装成功
    )
) else (
    echo [错误] 未找到前端 package.json 文件
)

:: 后端依赖检查
echo [检查] 检查后端项目...
cd "%PROJECT_PATH%VSS-backend"
if exist "pom.xml" (
    echo [完成] 后端项目配置正常，依赖将在首次运行时自动下载
) else (
    echo [错误] 未找到后端 pom.xml 文件
)

:: ===========================================
:: 创建启动脚本
:: ===========================================
echo.
echo [配置] 创建启动脚本...

:: 创建前端启动脚本
cd "%PROJECT_PATH%"
echo @echo off > start-frontend.bat
echo cd "VSS-frontend" >> start-frontend.bat
echo echo [启动] 前端开发服务器... >> start-frontend.bat
echo npm run dev >> start-frontend.bat
echo pause >> start-frontend.bat

:: 创建后端启动脚本
echo @echo off > start-backend.bat
echo cd "VSS-backend" >> start-backend.bat
echo echo [启动] 后端开发服务器... >> start-backend.bat
echo .\mvnw.cmd spring-boot:run >> start-backend.bat
echo pause >> start-backend.bat

:: 创建 Nginx 启动脚本
echo @echo off > start-nginx.bat
echo cd /d "%NGINX_PATH%" >> start-nginx.bat
echo echo [启动] Nginx 反向代理服务器... >> start-nginx.bat
echo start "" nginx.exe >> start-nginx.bat
echo echo Nginx 已启动，访问: http://localhost:8080 >> start-nginx.bat
echo echo 按任意键停止 Nginx... >> start-nginx.bat
echo pause ^>nul >> start-nginx.bat
echo nginx.exe -s quit >> start-nginx.bat

:: 创建一键启动脚本
echo @echo off > start-all.bat
echo setlocal enabledelayedexpansion >> start-all.bat
echo echo. >> start-all.bat
echo echo ======================================== >> start-all.bat
echo echo   VSS 开发环境一键启动 >> start-all.bat
echo echo ======================================== >> start-all.bat
echo echo. >> start-all.bat
echo echo [1] 启动后端服务器... >> start-all.bat
echo start "VSS-Backend" cmd /k "start-backend.bat" >> start-all.bat
echo timeout /t 3 /nobreak ^>nul >> start-all.bat
echo echo [2] 启动前端服务器... >> start-all.bat
echo start "VSS-Frontend" cmd /k "start-frontend.bat" >> start-all.bat
echo timeout /t 3 /nobreak ^>nul >> start-all.bat
echo echo [3] 启动 Nginx 代理... >> start-all.bat
echo start "VSS-Nginx" cmd /k "start-nginx.bat" >> start-all.bat
echo echo. >> start-all.bat
echo echo 所有服务启动完成！ >> start-all.bat
echo echo 访问地址: http://localhost:8080 >> start-all.bat
echo echo. >> start-all.bat
echo pause >> start-all.bat

:: 创建环境变量设置脚本
echo @echo off > set-env.bat
echo echo 设置环境变量... >> set-env.bat
echo setx PATH "%%PATH%%;%NGINX_PATH%" >> set-env.bat
echo echo 环境变量设置完成 >> set-env.bat
echo pause >> set-env.bat

goto :success

:: ===========================================
:: 手动安装指导
:: ===========================================
:manual_install
echo.
echo ==========================================
echo   手动安装指导
echo ==========================================
echo.
echo 请手动完成以下安装：
echo.

:manual_nodejs
echo [Node.js] 请访问: https://nodejs.org/
echo   下载并安装 LTS 版本
echo.

:manual_java
echo [Java JDK] 请访问: https://adoptium.net/
echo   下载并安装 OpenJDK 17
echo.

:manual_maven
echo [Maven] 请访问: https://maven.apache.org/download.cgi
echo   下载并安装最新版本
echo.

:manual_nginx
echo [Nginx] 请访问: http://nginx.org/en/download.html
echo   下载 Windows 版本并解压到: %NGINX_PATH%
echo.

:manual_git
echo [Git] 请访问: https://git-scm.com/download/win
echo   下载并安装最新版本
echo.

echo 完成手动安装后，请重新运行此脚本继续配置项目依赖。
goto :end

:: ===========================================
:: 安装成功
:: ===========================================
:success
echo.
echo ==========================================
echo   安装完成！
echo ==========================================
echo.
echo 已创建以下启动脚本：
echo   start-frontend.bat  - 启动前端开发服务器
echo   start-backend.bat   - 启动后端开发服务器  
echo   start-nginx.bat     - 启动 Nginx 代理
echo   start-all.bat       - 一键启动所有服务
echo   set-env.bat         - 设置环境变量
echo.
echo 安装目录：
echo   Node.js: %NODE_PATH%
echo   Java:    %JAVA_PATH%
echo   Maven:   %MAVEN_PATH%
echo   Nginx:   %NGINX_PATH%
echo.
echo 使用方法：
echo   1. 双击 'start-all.bat' 一键启动所有服务
echo   2. 访问 http://localhost:8080 查看应用
echo   3. 前端开发: http://localhost:3000
echo   4. 后端开发: http://localhost:3002
echo.
echo 注意事项：
echo   - 首次启动后端可能需要较长时间下载依赖
echo   - 确保端口 3000, 3002, 8080 未被占用
echo   - 如有问题请查看各服务的启动日志
echo.

:end
echo 按任意键退出...
pause >nul
