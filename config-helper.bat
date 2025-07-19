@echo off
REM VSS 配置修改助手

echo.
echo ========================================
echo           VSS 配置修改助手
echo ========================================
echo.

echo 当前支持的配置类型：
echo 1) 端口配置
echo 2) 数据库配置  
echo 3) API 配置
echo 4) 查看当前配置
echo 5) 验证配置
echo.
set /p choice=请选择要修改的配置类型 (1-5): 

if "%choice%"=="1" goto ports
if "%choice%"=="2" goto database
if "%choice%"=="3" goto api
if "%choice%"=="4" goto show
if "%choice%"=="5" goto validate
goto invalid

:ports
echo.
echo 端口配置修改
echo ========================================
echo.
echo 当前端口配置：
if exist "config-manager.js" (
    node config-manager.js ports dev
) else (
    echo 开发环境: 前端=3001, 后端=3003
    echo 生产环境: 前端=3000, 后端=3002
)
echo.
echo 要修改端口配置，请编辑以下文件：
echo   .env.development  - 开发环境端口
echo   .env.production   - 生产环境端口
echo.
echo 修改后运行以下命令验证：
echo   node config-manager.js validate dev
echo   node config-manager.js validate prod
goto end

:database
echo.
echo 数据库配置修改
echo ========================================
echo.
echo 支持的数据库类型：
echo   h2        - H2 内存数据库（开发推荐）
echo   postgres  - PostgreSQL（生产推荐）
echo   mysql     - MySQL
echo.
echo 配置参数：
echo   DB_TYPE     - 数据库类型
echo   DB_HOST     - 数据库主机
echo   DB_PORT     - 数据库端口
echo   DB_NAME     - 数据库名称
echo   DB_USERNAME - 用户名
echo   DB_PASSWORD - 密码
echo.
echo 请在对应的 .env 文件中修改这些参数
goto end

:api
echo.
echo API 配置修改
echo ========================================
echo.
echo 可配置的 API 参数：
echo   API_BASE_URL    - API 基础地址
echo   API_PREFIX      - API 路径前缀（如 /api/v1）
echo   API_TIMEOUT     - 请求超时时间（毫秒）
echo   API_RATE_LIMIT  - 请求频率限制
echo.
echo 前端相关配置：
echo   VITE_API_BASE_URL - 前端使用的 API 地址
echo   VITE_APP_TITLE    - 应用标题
echo.
echo 请在对应的 .env 文件中修改这些参数
goto end

:show
echo.
echo 显示当前配置
echo ========================================
if exist "config-manager.js" (
    echo.
    echo 开发环境配置：
    node config-manager.js show dev
    echo.
    echo 生产环境配置：
    node config-manager.js show prod
) else (
    echo 配置管理工具不可用，请检查 config-manager.js 文件
)
goto end

:validate
echo.
echo 验证配置文件
echo ========================================
if exist "config-manager.js" (
    echo 验证开发环境配置：
    node config-manager.js validate dev
    echo.
    echo 验证生产环境配置：
    node config-manager.js validate prod
) else (
    echo 配置管理工具不可用，请检查 config-manager.js 文件
)
goto end

:invalid
echo 无效选择，请重新运行脚本
goto end

:end
echo.
echo ========================================
echo 配置修改后，请运行以下命令应用更改：
echo   docker-manage.bat stop    - 停止当前服务
echo   docker-manage.bat dev     - 启动开发环境
echo   docker-manage.bat start   - 启动生产环境
echo ========================================
echo.
pause
