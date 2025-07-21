@echo off
:: =============================================================================
:: VSS项目子模块管理脚本 (Windows版本)
:: 功能: 自动化Git子模块的初始化、更新和管理
:: 作者: VSS开发团队
:: 版本: 1.0.0
:: =============================================================================

setlocal enabledelayedexpansion

:: 设置编码为UTF-8
chcp 65001 >nul

:: 颜色配置 (Windows命令行颜色代码)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

:: 日志函数
:log_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:log_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:log_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:log_error
echo %RED%[ERROR]%NC% %~1
goto :eof

:: 检查Git仓库状态
:check_git_status
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    call :log_error "当前目录不是Git仓库"
    exit /b 1
)

if not exist ".gitmodules" (
    call :log_warning "未找到.gitmodules文件"
    exit /b 1
)
exit /b 0

:: 初始化所有子模块
:init_submodules
call :log_info "🚀 初始化所有子模块..."

git submodule update --init --recursive
if errorlevel 1 (
    call :log_error "❌ 子模块初始化失败"
    exit /b 1
)

call :log_success "✅ 所有子模块初始化完成"
call :list_submodules
exit /b 0

:: 更新所有子模块
:update_submodules
call :log_info "🔄 更新所有子模块到最新版本..."

:: 获取更新前的子模块状态
git submodule status > temp_before.txt

:: 更新子模块
git submodule update --remote --recursive
if errorlevel 1 (
    call :log_error "❌ 子模块更新失败"
    del temp_before.txt
    exit /b 1
)

:: 获取更新后的状态
git submodule status > temp_after.txt

:: 比较状态文件
fc temp_before.txt temp_after.txt >nul 2>&1
if errorlevel 1 (
    call :log_info "📦 检测到子模块更新，准备提交..."
    
    :: 提交更新
    git add .
    git commit -m "Update: 自动更新所有子模块到最新版本"
    
    call :log_success "✅ 子模块更新已提交"
) else (
    call :log_success "✅ 所有子模块都是最新版本"
)

:: 清理临时文件
del temp_before.txt temp_after.txt
exit /b 0

:: 添加新的子模块
:add_submodule
if "%~2"=="" (
    call :log_error "使用方法: add_submodule <仓库URL> <本地路径>"
    exit /b 1
)

set "repo_url=%~1"
set "local_path=%~2"

call :log_info "➕ 添加新子模块: %repo_url% -> %local_path%"

:: 检查路径是否已存在
if exist "%local_path%" (
    call :log_error "路径 %local_path% 已存在"
    exit /b 1
)

:: 添加子模块
git submodule add "%repo_url%" "%local_path%"
if errorlevel 1 (
    call :log_error "❌ 子模块添加失败"
    exit /b 1
)

git add .gitmodules "%local_path%"
git commit -m "Add: 添加子模块 %local_path%"

call :log_success "✅ 子模块 %local_path% 添加成功"
exit /b 0

:: 删除子模块
:remove_submodule
if "%~1"=="" (
    call :log_error "使用方法: remove_submodule <子模块路径>"
    exit /b 1
)

set "submodule_path=%~1"

call :log_info "🗑️ 删除子模块: %submodule_path%"

:: 检查子模块是否存在
git submodule status | findstr "%submodule_path%" >nul
if errorlevel 1 (
    call :log_error "子模块 %submodule_path% 不存在"
    exit /b 1
)

:: 删除子模块
git submodule deinit -f "%submodule_path%"
git rm -f "%submodule_path%"
if exist ".git\modules\%submodule_path%" (
    rmdir /s /q ".git\modules\%submodule_path%"
)

git commit -m "Remove: 删除子模块 %submodule_path%"

call :log_success "✅ 子模块 %submodule_path% 删除成功"
exit /b 0

:: 列出所有子模块
:list_submodules
call :log_info "📋 子模块列表:"
echo.

call :check_git_status
if errorlevel 1 (
    call :log_warning "没有找到子模块配置"
    exit /b 0
)

echo %-30s %-20s %-40s
echo 路径                          分支                  仓库URL
echo ------------------------------  --------------------  ----------------------------------------

:: 解析.gitmodules文件
for /f "tokens=*" %%a in (.gitmodules) do (
    set "line=%%a"
    if "!line:~0,11!"=="[submodule " (
        :: 提取子模块名称
        set "submodule_name=!line:~12,-2!"
    )
    if "!line:~0,8!"=="	path = " (
        set "path=!line:~8!"
    )
    if "!line:~0,7!"=="	url = " (
        set "url=!line:~7!"
    )
    if "!line:~0,10!"=="	branch = " (
        set "branch=!line:~10!"
    )
    if "!line!"=="" if defined path (
        if not defined branch set "branch=main"
        echo !path!                          !branch!                  !url!
        set "path="
        set "url="
        set "branch="
    )
)

:: 处理最后一个子模块
if defined path (
    if not defined branch set "branch=main"
    echo !path!                          !branch!                  !url!
)

echo.
exit /b 0

:: 检查子模块状态
:status_submodules
call :log_info "📊 子模块状态检查:"
echo.

git submodule status

echo.
call :log_info "🔍 详细状态:"

git submodule foreach --quiet "echo 📁 子模块: %name% && echo    路径: %sm_path% && git log -1 --format='   提交: %%H' && git branch --show-current && echo."

exit /b 0

:: 同步所有子模块
:sync_submodules
call :log_info "🔄 同步所有子模块..."

git submodule sync --recursive
if errorlevel 1 (
    call :log_error "❌ 子模块同步失败"
    exit /b 1
)

call :log_success "✅ 子模块同步完成"
exit /b 0

:: 重置所有子模块
:reset_submodules
call :log_warning "⚠️ 这将重置所有子模块，丢失未提交的更改！"
set /p "confirm=确定要继续吗? (y/N): "

if /i "%confirm%"=="y" (
    call :log_info "🔄 重置所有子模块..."
    
    git submodule deinit --all -f
    git submodule update --init --recursive
    
    call :log_success "✅ 所有子模块已重置"
) else (
    call :log_info "操作已取消"
)
exit /b 0

:: 显示帮助信息
:show_help
echo VSS项目子模块管理脚本 (Windows版本)
echo.
echo 使用方法:
echo   manage-submodules.bat ^<命令^> [参数]
echo.
echo 命令:
echo   init                    初始化所有子模块
echo   update                  更新所有子模块到最新版本
echo   add ^<url^> ^<path^>        添加新的子模块
echo   remove ^<path^>           删除指定子模块
echo   list                    列出所有子模块
echo   status                  检查子模块状态
echo   sync                    同步子模块URL配置
echo   reset                   重置所有子模块（危险操作）
echo   help                    显示此帮助信息
echo.
echo 示例:
echo   manage-submodules.bat init
echo   manage-submodules.bat add https://github.com/user/repo.git ./path/to/submodule
echo   manage-submodules.bat update
echo.
exit /b 0

:: 主函数
:main
if "%~1"=="" goto show_help
if "%~1"=="help" goto show_help
if "%~1"=="-h" goto show_help
if "%~1"=="--help" goto show_help

if "%~1"=="init" (
    call :init_submodules
    goto :eof
)

if "%~1"=="update" (
    call :update_submodules
    goto :eof
)

if "%~1"=="add" (
    call :add_submodule "%~2" "%~3"
    goto :eof
)

if "%~1"=="remove" (
    call :remove_submodule "%~2"
    goto :eof
)

if "%~1"=="list" (
    call :list_submodules
    goto :eof
)

if "%~1"=="status" (
    call :status_submodules
    goto :eof
)

if "%~1"=="sync" (
    call :sync_submodules
    goto :eof
)

if "%~1"=="reset" (
    call :reset_submodules
    goto :eof
)

call :log_error "未知命令: %~1"
echo.
call :show_help
exit /b 1

:: 执行主函数
call :main %*
