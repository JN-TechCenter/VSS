@echo off
setlocal enabledelayedexpansion

:: 设置编码为UTF-8
chcp 65001 >nul

echo 开始推送所有子模块到GitHub...

:: 检查Git仓库状态
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo 错误: 当前目录不是Git仓库
    exit /b 1
)

if not exist ".gitmodules" (
    echo 警告: 未找到.gitmodules文件
    exit /b 1
)

:: 获取所有子模块路径并处理
echo.
echo 正在处理子模块: inference-server
if exist "inference-server" (
    cd inference-server
    
    :: 检查是否处于分离头状态
    git symbolic-ref -q HEAD >nul 2>&1
    if errorlevel 1 (
        echo 子模块处于分离头状态，尝试切换到主分支...
        git checkout main 2>nul || git checkout master 2>nul || git checkout dev 2>nul
        if errorlevel 1 (
            echo 无法切换到有效分支，跳过此子模块
            cd ..
            goto :skip_inference
        )
    )
    :: 再次获取当前分支名
    for /f "tokens=*" %%b in ('git branch --show-current') do set "branch=%%b"
    if not defined branch (
        echo 未能获取当前分支名，跳过此子模块
        cd ..
        goto :skip_inference
    )
    echo 当前分支: !branch!
    :: 添加、提交和推送
    git add .
    git commit -m "自动提交更改" || echo 没有需要提交的更改
    git push origin !branch! || echo 推送失败，可能需要设置SSH密钥或检查权限
    set "branch="
    cd ..
    echo 子模块 inference-server 处理完成
) else (
    echo 子模块目录 inference-server 不存在，跳过
)
:skip_inference

echo.
echo 正在处理子模块: VSS-frontend
if exist "VSS-frontend" (
    cd VSS-frontend
    
    :: 检查是否处于分离头状态
    git symbolic-ref -q HEAD >nul 2>&1
    if errorlevel 1 (
        echo 子模块处于分离头状态，尝试切换到主分支...
        git checkout main 2>nul || git checkout master 2>nul || git checkout dev 2>nul
        if errorlevel 1 (
            echo 无法切换到有效分支，跳过此子模块
            cd ..
            goto :skip_frontend
        )
    )
    :: 再次获取当前分支名
    for /f "tokens=*" %%b in ('git branch --show-current') do set "branch=%%b"
    if not defined branch (
        echo 未能获取当前分支名，跳过此子模块
        cd ..
        goto :skip_frontend
    )
    echo 当前分支: !branch!
    :: 添加、提交和推送
    git add .
    git commit -m "自动提交更改" || echo 没有需要提交的更改
    git push origin !branch! || echo 推送失败，可能需要设置SSH密钥或检查权限
    set "branch="
    cd ..
    echo 子模块 VSS-frontend 处理完成
) else (
    echo 子模块目录 VSS-frontend 不存在，跳过
)
:skip_frontend

echo.
echo 正在处理子模块: VSS-backend
if exist "VSS-backend" (
    cd VSS-backend
    
    :: 检查是否处于分离头状态
    git symbolic-ref -q HEAD >nul 2>&1
    if errorlevel 1 (
        echo 子模块处于分离头状态，尝试切换到主分支...
        git checkout main 2>nul || git checkout master 2>nul || git checkout dev 2>nul
        if errorlevel 1 (
            echo 无法切换到有效分支，跳过此子模块
            cd ..
            goto :skip_backend
        )
    )
    :: 再次获取当前分支名
    for /f "tokens=*" %%b in ('git branch --show-current') do set "branch=%%b"
    if not defined branch (
        echo 未能获取当前分支名，跳过此子模块
        cd ..
        goto :skip_backend
    )
    echo 当前分支: !branch!
    :: 添加、提交和推送
    git add .
    git commit -m "自动提交更改" || echo 没有需要提交的更改
    git push origin !branch! || echo 推送失败，可能需要设置SSH密钥或检查权限
    set "branch="
    cd ..
    echo 子模块 VSS-backend 处理完成
) else (
    echo 子模块目录 VSS-backend 不存在，跳过
)
:skip_backend

echo.
echo 正在处理子模块: net-framework-server
if exist "net-framework-server" (
    cd net-framework-server
    
    :: 检查是否处于分离头状态
    git symbolic-ref -q HEAD >nul 2>&1
    if errorlevel 1 (
        echo 子模块处于分离头状态，尝试切换到主分支...
        git checkout main 2>nul || git checkout master 2>nul || git checkout dev 2>nul
        if errorlevel 1 (
            echo 无法切换到有效分支，跳过此子模块
            cd ..
            goto :skip_netframework
        )
    )
    :: 再次获取当前分支名
    for /f "tokens=*" %%b in ('git branch --show-current') do set "branch=%%b"
    if not defined branch (
        echo 未能获取当前分支名，跳过此子模块
        cd ..
        goto :skip_netframework
    )
    echo 当前分支: !branch!
    :: 添加、提交和推送
    git add .
    git commit -m "自动提交更改" || echo 没有需要提交的更改
    git push origin !branch! || echo 推送失败，可能需要设置SSH密钥或检查权限
    set "branch="
    cd ..
    echo 子模块 net-framework-server 处理完成
) else (
    echo 子模块目录 net-framework-server 不存在，跳过
)
:skip_netframework

echo.
echo 正在处理子模块: data-analysis-server
if exist "data-analysis-server" (
    cd data-analysis-server
    
    :: 检查是否处于分离头状态
    git symbolic-ref -q HEAD >nul 2>&1
    if errorlevel 1 (
        echo 子模块处于分离头状态，尝试切换到主分支...
        git checkout main 2>nul || git checkout master 2>nul || git checkout dev 2>nul
        if errorlevel 1 (
            echo 无法切换到有效分支，跳过此子模块
            cd ..
            goto :skip_dataanalysis
        )
    )
    :: 再次获取当前分支名
    for /f "tokens=*" %%b in ('git branch --show-current') do set "branch=%%b"
    if not defined branch (
        echo 未能获取当前分支名，跳过此子模块
        cd ..
        goto :skip_dataanalysis
    )
    echo 当前分支: !branch!
    :: 添加、提交和推送
    git add .
    git commit -m "自动提交更改" || echo 没有需要提交的更改
    git push origin !branch! || echo 推送失败，可能需要设置SSH密钥或检查权限
    set "branch="
    cd ..
    echo 子模块 data-analysis-server 处理完成
) else (
    echo 子模块目录 data-analysis-server 不存在，跳过
)
:skip_dataanalysis

echo.
echo 所有子模块处理完成

pause