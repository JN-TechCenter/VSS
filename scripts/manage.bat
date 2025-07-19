@echo off
setlocal enabledelayedexpansion

echo 🚀 VSS 项目管理助手
echo ===================

if "%1"=="" goto :menu
if "%1"=="status" goto :status
if "%1"=="s" goto :status  
if "%1"=="update" goto :update
if "%1"=="u" goto :update
if "%1"=="dev" goto :dev
if "%1"=="d" goto :dev
goto :menu

:status
echo 📊 项目状态
echo ----------
call :check_status "." "主项目"
if exist "VSS-frontend" call :check_status "VSS-frontend" "前端项目"
if exist "VSS-backend" call :check_status "VSS-backend" "后端项目"
goto :end

:update  
echo 🔄 更新所有仓库
echo ---------------
call :update_repo "." "主项目"
if exist "VSS-frontend" call :update_repo "VSS-frontend" "前端项目" 
if exist "VSS-backend" call :update_repo "VSS-backend" "后端项目"
goto :end

:dev
echo 🛠️  启动开发环境
echo ---------------

if exist "VSS-backend" (
    echo 🌱 启动后端服务...
    cd VSS-backend
    start "VSS-Backend" mvn spring-boot:run
    cd ..
    echo ✅ 后端服务启动中
)

if exist "VSS-frontend" (
    echo 🎨 启动前端服务...
    cd VSS-frontend  
    start "VSS-Frontend" npm run dev
    cd ..
    echo ✅ 前端服务启动中
)

echo.
echo 🌐 服务地址：
echo    前端: http://localhost:3000
echo    后端: http://localhost:3002
goto :end

:check_status
cd %1
echo 📁 检查 %~2...
git status --short 2>nul
if errorlevel 1 (
    echo ❌ %~2 不是Git仓库
) else (
    for /f %%i in ('git status --porcelain ^| find /c /v ""') do (
        if %%i gtr 0 (
            echo ⚠️  %~2 有未提交的更改
        ) else (
            echo ✅ %~2 工作目录干净
        )
    )
)
cd ..
echo.
goto :eof

:update_repo
cd %1
echo 🔄 更新 %~2...
git fetch 2>nul
if errorlevel 1 (
    echo ❌ 无法连接到远程仓库
) else (
    git pull origin main
    echo ✅ %~2 更新完成
)
cd ..
echo.
goto :eof

:menu
echo 使用方法：
echo   %0 status   (s) - 显示所有仓库状态
echo   %0 update   (u) - 更新所有仓库  
echo   %0 dev      (d) - 启动开发环境
echo.
echo 示例：
echo   %0 s        # 检查状态
echo   %0 u        # 更新项目
echo   %0 d        # 开始开发

:end
pause
