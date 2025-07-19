@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 配置管理脚本 - Windows 版本
REM 用途：管理 VSS 视觉平台的环境配置

set BASE_ENV=.env
set DEV_ENV=.env.development
set PROD_ENV=.env.production
set DOCKER_ENV=.env.docker

REM 主程序逻辑
if "%1"=="" (
    call :show_help
    goto :eof
)

if "%1"=="validate" (
    call :validate_config %2
) else if "%1"=="load" (
    call :load_environment %2
) else if "%1"=="show" (
    call :show_config %2
) else if "%1"=="docker" (
    call :generate_docker_env %2
) else if "%1"=="help" (
    call :show_help
) else (
    echo ❌ 未知命令: %1
    call :show_help
)
goto :eof

REM 显示帮助
:show_help
echo.
echo ⚙️  VSS 配置管理工具
echo.
echo 用法: config-manage.bat [命令] [环境]
echo.
echo 命令:
echo   validate [env] - 验证配置文件
echo   load [env]     - 加载环境配置
echo   show [env]     - 显示配置内容
echo   docker [env]   - 生成Docker环境文件
echo   help          - 显示帮助
echo.
echo 环境:
echo   dev   - 开发环境
echo   prod  - 生产环境
echo   (空)  - 基础配置
echo.
echo 示例:
echo   config-manage.bat validate dev
echo   config-manage.bat load prod
echo   config-manage.bat docker dev
echo.
goto :eof

REM 验证配置文件
:validate_config
set ENV_TYPE=%1
echo 🔍 验证配置文件...

REM 检查基础配置文件
if not exist "%BASE_ENV%" (
    echo ❌ 缺少基础配置文件: %BASE_ENV%
    exit /b 1
)
echo ✅ 基础配置文件存在

REM 检查环境特定配置文件
if "%ENV_TYPE%"=="dev" (
    if not exist "%DEV_ENV%" (
        echo ❌ 缺少开发环境配置文件: %DEV_ENV%
        exit /b 1
    )
    echo ✅ 开发环境配置文件存在
) else if "%ENV_TYPE%"=="prod" (
    if not exist "%PROD_ENV%" (
        echo ❌ 缺少生产环境配置文件: %PROD_ENV%
        exit /b 1
    )
    echo ✅ 生产环境配置文件存在
)

REM 验证必需的环境变量
call :check_required_vars %ENV_TYPE%

echo ✅ 配置验证完成
goto :eof

REM 检查必需的环境变量
:check_required_vars
set ENV_TYPE=%1
echo 🔍 检查必需的环境变量...

REM 从基础配置读取
for /f "usebackq tokens=1,2 delims==" %%a in ("%BASE_ENV%") do (
    set "%%a=%%b"
)

REM 从环境特定配置读取（如果存在）
if "%ENV_TYPE%"=="dev" (
    if exist "%DEV_ENV%" (
        for /f "usebackq tokens=1,2 delims==" %%a in ("%DEV_ENV%") do (
            set "%%a=%%b"
        )
    )
) else if "%ENV_TYPE%"=="prod" (
    if exist "%PROD_ENV%" (
        for /f "usebackq tokens=1,2 delims==" %%a in ("%PROD_ENV%") do (
            set "%%a=%%b"
        )
    )
)

REM 检查必需变量
call :check_var FRONTEND_PORT "前端端口"
call :check_var BACKEND_PORT "后端端口"
call :check_var NODE_ENV "Node环境"

goto :eof

REM 检查单个变量
:check_var
set VAR_NAME=%1
set VAR_DESC=%2
set VAR_VALUE=
for /f "tokens=*" %%a in ('echo !%VAR_NAME%!') do set VAR_VALUE=%%a

if "!VAR_VALUE!"=="" (
    echo ❌ 缺少必需变量: %VAR_NAME% ^(%VAR_DESC%^)
) else (
    echo ✅ %VAR_NAME%=!VAR_VALUE!
)
goto :eof

REM 加载环境配置
:load_environment
set ENV_TYPE=%1
echo 📥 加载环境配置: %ENV_TYPE%

REM 加载基础配置
if exist "%BASE_ENV%" (
    echo 📋 加载基础配置...
    for /f "usebackq tokens=1,2 delims==" %%a in ("%BASE_ENV%") do (
        set "%%a=%%b"
    )
)

REM 加载环境特定配置
if "%ENV_TYPE%"=="dev" (
    if exist "%DEV_ENV%" (
        echo 🛠️  加载开发环境配置...
        for /f "usebackq tokens=1,2 delims==" %%a in ("%DEV_ENV%") do (
            set "%%a=%%b"
        )
    )
) else if "%ENV_TYPE%"=="prod" (
    if exist "%PROD_ENV%" (
        echo 🏭 加载生产环境配置...
        for /f "usebackq tokens=1,2 delims==" %%a in ("%PROD_ENV%") do (
            set "%%a=%%b"
        )
    )
)

echo ✅ 环境配置加载完成
goto :eof

REM 显示配置内容
:show_config
set ENV_TYPE=%1
echo 📋 配置内容 ^(%ENV_TYPE%^):
echo.

echo [基础配置] - %BASE_ENV%
if exist "%BASE_ENV%" (
    type "%BASE_ENV%"
) else (
    echo   文件不存在
)

echo.
if "%ENV_TYPE%"=="dev" (
    echo [开发环境] - %DEV_ENV%
    if exist "%DEV_ENV%" (
        type "%DEV_ENV%"
    ) else (
        echo   文件不存在
    )
) else if "%ENV_TYPE%"=="prod" (
    echo [生产环境] - %PROD_ENV%
    if exist "%PROD_ENV%" (
        type "%PROD_ENV%"
    ) else (
        echo   文件不存在
    )
)

echo.
goto :eof

REM 生成Docker环境文件
:generate_docker_env
set ENV_TYPE=%1
echo 🐳 生成Docker环境文件: %ENV_TYPE%

REM 创建临时合并文件
set TEMP_FILE=%TEMP%\vss_env_%RANDOM%.tmp

REM 复制基础配置
if exist "%BASE_ENV%" (
    copy "%BASE_ENV%" "%TEMP_FILE%" >nul
)

REM 追加环境特定配置
if "%ENV_TYPE%"=="dev" (
    if exist "%DEV_ENV%" (
        type "%DEV_ENV%" >> "%TEMP_FILE%"
    )
) else if "%ENV_TYPE%"=="prod" (
    if exist "%PROD_ENV%" (
        type "%PROD_ENV%" >> "%TEMP_FILE%"
    )
)

REM 生成最终的Docker环境文件
if exist "%TEMP_FILE%" (
    copy "%TEMP_FILE%" "%DOCKER_ENV%" >nul
    del "%TEMP_FILE%" >nul
    echo ✅ Docker环境文件已生成: %DOCKER_ENV%
) else (
    echo ❌ 生成Docker环境文件失败
    exit /b 1
)

goto :eof
