@echo off
REM VSS 项目子模块管理脚本
REM 用于管理前端、后端和AI推理服务三个子模块

echo.
echo ========================================
echo     VSS 项目子模块管理工具
echo ========================================
echo.

if "%1"=="" goto show_help
if "%1"=="status" goto show_status
if "%1"=="init" goto init_submodules
if "%1"=="update" goto update_submodules
if "%1"=="pull" goto pull_latest
if "%1"=="links" goto show_links
if "%1"=="help" goto show_help
goto show_help

:show_status
echo [信息] 检查子模块状态...
echo.
git submodule status
echo.
echo 图例:
echo   无前缀  = 子模块已初始化且最新
echo   -       = 子模块未初始化
echo   +       = 子模块有新提交可用
echo   U       = 子模块有冲突
echo.
goto end

:init_submodules
echo [操作] 初始化所有子模块...
git submodule update --init --recursive
echo.
echo [完成] 所有子模块已初始化
goto show_status

:update_submodules
echo [操作] 更新所有子模块到最新版本...
git submodule update --remote --recursive
echo.
echo [完成] 所有子模块已更新到最新版本
goto show_status

:pull_latest
echo [操作] 拉取主项目和所有子模块的最新更改...
git pull origin main
git submodule update --remote --recursive
echo.
echo [完成] 主项目和子模块都已更新到最新版本
goto show_status

:show_links
echo [信息] VSS 项目子模块仓库链接:
echo.
echo 🎨 前端服务 (React + TypeScript)
echo    📁 本地路径: .\VSS-frontend\
echo    🔗 GitHub:   https://github.com/JN-TechCenter/VSS-frontend
echo    📋 技术栈:   React, TypeScript, Vite, TailwindCSS
echo.
echo ⚙️ 后端服务 (Spring Boot + Java)
echo    📁 本地路径: .\VSS-backend\
echo    🔗 GitHub:   https://github.com/JN-TechCenter/VSS-backend  
echo    📋 技术栈:   Spring Boot, Java 17, JPA, PostgreSQL
echo.
echo 🤖 AI推理服务 (Python + FastAPI)
echo    📁 本地路径: .\inference_server\
echo    🔗 GitHub:   https://github.com/JN-TechCenter/inference_server
echo    📋 技术栈:   Python, FastAPI, PyTorch, YOLO
echo.
goto end

:show_help
echo 使用方法: submodules.bat [命令]
echo.
echo 可用命令:
echo   status    - 显示所有子模块的状态
echo   init      - 初始化所有子模块 (首次使用)
echo   update    - 更新所有子模块到最新版本
echo   pull      - 拉取主项目和子模块的最新更改
echo   links     - 显示所有子模块的仓库链接信息
echo   help      - 显示此帮助信息
echo.
echo 示例:
echo   submodules.bat status     # 查看状态
echo   submodules.bat init       # 首次初始化
echo   submodules.bat update     # 更新到最新
echo   submodules.bat links      # 查看仓库链接
echo.
goto end

:end
echo ========================================
