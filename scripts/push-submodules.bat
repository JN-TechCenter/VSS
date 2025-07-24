@echo off
:: =============================================================================
:: VSS项目子模块推送脚本 (Windows版本)
:: 功能: 自动化Git子模块的提交和推送到GitHub
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
echo %BLUE%[INFO]%NC% %*
goto :eof

:log_success
echo %GREEN%[SUCCESS]%NC% %*
goto :eof

:log_warning
echo %YELLOW%[WARNING]%NC% %*
goto :eof

:log_error
echo %RED%[ERROR]%NC% %*
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

:: 推送所有子模块
:push_submodules
call :log_info "🚀 开始推送所有子模块到GitHub..."

:: 检查Git仓库状态
call :check_git_status
if errorlevel 1 exit /b 1

:: 获取所有子模块路径
for /f "tokens=1,2" %%i in ('git config --file .gitmodules --get-regexp path') do (
    set "submodule_path=%%j"
    call :push_single_submodule "!submodule_path!"
)

call :log_success "✅ 所有子模块推送完成"
exit /b 0

:: 推送单个子模块
:push_single_submodule
set "submodule_path=%~1"
call :log_info "📦 处理子模块: %submodule_path%"

:: 检查子模块目录是否存在
if not exist "%submodule_path%" (
    call :log_warning "子模块目录 %submodule_path% 不存在，跳过"
    exit /b 0
)

:: 进入子模块目录
pushd "%submodule_path%"

:: 检查是否是Git仓库
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    call :log_warning "目录 %submodule_path% 不是Git仓库，跳过"
    popd
    exit /b 0
)

:: 获取当前分支
for /f "tokens=*" %%b in ('git branch --show-current') do set "current_branch=%%b"

:: 检查是否有更改
git status --porcelain >temp_status.txt 2>nul
if errorlevel 1 (
    call :log_warning "子模块 %submodule_path% 检查状态失败，跳过"
    popd
    exit /b 0
)

set "changes=0"
for /f "tokens=*" %%c in (temp_status.txt) do set /a "changes+=1"
del temp_status.txt >nul 2>&1

if "%changes%"=="0" (
    call :log_info "子模块 %submodule_path% 没有需要提交的更改"
) else (
    call :log_info "子模块 %submodule_path% 有 %changes% 个更改需要提交"
    
    :: 添加所有更改
    git add .
    
    :: 提交更改
    set /p commit_message=请输入提交信息 [自动提交更改]: 
    if "!commit_message!"=="" set "commit_message=自动提交更改"
    
    git commit -m "!commit_message!"
    if errorlevel 1 (
        call :log_error "子模块 %submodule_path% 提交失败"
        popd
        exit /b 1
    )
    
    call :log_success "子模块 %submodule_path% 提交成功"
)

:: 推送到远程仓库
call :log_info "推送子模块 %submodule_path% 到远程仓库 (分支: %current_branch%)..."

git push origin %current_branch%
if errorlevel 1 (
    call :log_error "子模块 %submodule_path% 推送失败"
    popd
    exit /b 1
)

call :log_success "子模块 %submodule_path% 推送成功"

:: 返回上级目录
popd
exit /b 0

:: 显示帮助信息
:show_help
echo VSS项目子模块推送脚本 (Windows版本)
echo.
echo 使用方法:
echo   push-submodules.bat
echo.
echo 功能:
echo   自动进入每个子模块目录，提交更改并推送到GitHub仓库
echo.
exit /b 0

:: 主函数
:main
if "%~1"=="help" goto show_help
if "%~1"=="-h" goto show_help
if "%~1"=="--help" goto show_help

call :push_submodules
goto :eof

:: 执行主函数
call :main %*