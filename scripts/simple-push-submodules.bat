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

:: 获取所有子模块路径
for /f "tokens=1,2" %%i in ('git config --file .gitmodules --get-regexp path') do (
    set "submodule_path=%%j"
    
    echo.
    echo 处理子模块: !submodule_path!
    
    :: 检查子模块目录是否存在
    if not exist "!submodule_path!" (
        echo 警告: 子模块目录 !submodule_path! 不存在，跳过
        goto :continue
    )
    
    :: 进入子模块目录
    pushd "!submodule_path!"
    
    :: 检查是否是Git仓库
    git rev-parse --git-dir >nul 2>&1
    if errorlevel 1 (
        echo 警告: 目录 !submodule_path! 不是Git仓库，跳过
        popd
        goto :continue
    )
    
    :: 获取当前分支
    for /f "tokens=*" %%b in ('git branch --show-current') do set "current_branch=%%b"
    
    :: 检查是否有更改
    git status --porcelain > temp_status.txt 2>nul
    
    set "changes=0"
    for /f "tokens=*" %%c in (temp_status.txt) do set /a "changes+=1"
    del temp_status.txt >nul 2>&1
    
    if "!changes!"=="0" (
        echo 子模块 !submodule_path! 没有需要提交的更改
    ) else (
        echo 子模块 !submodule_path! 有 !changes! 个更改需要提交
        
        :: 添加所有更改
        git add .
        
        :: 提交更改
        set /p commit_message=请输入提交信息 [自动提交更改]: 
        if "!commit_message!"=="" set "commit_message=自动提交更改"
        
        git commit -m "!commit_message!"
        if errorlevel 1 (
            echo 错误: 子模块 !submodule_path! 提交失败
            popd
            goto :continue
        )
        
        echo 子模块 !submodule_path! 提交成功
    )
    
    :: 推送到远程仓库
    echo 推送子模块 !submodule_path! 到远程仓库 ^(分支: !current_branch!^)...
    
    git push origin !current_branch!
    if errorlevel 1 (
        echo 错误: 子模块 !submodule_path! 推送失败
        popd
        goto :continue
    )
    
    echo 子模块 !submodule_path! 推送成功
    
    :: 返回上级目录
    popd
    
    :continue
)

echo.
echo 所有子模块处理完成

pause