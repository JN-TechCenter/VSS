@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: VSS Git Management Tool
:: Unified Git operations for main repository and submodules

echo.
echo ========================================
echo           VSS Git Management Tool
echo ========================================
echo.

if "%~1"=="" (
    call :show_help
    goto :eof
)

if "%~1"=="help" (
    call :show_help
    goto :eof
)

if "%~1"=="pull" (
    call :pull_all
    goto :eof
)

if "%~1"=="push" (
    set AUTO_MODE=1
    call :push_all
    goto :eof
)

if "%~1"=="push-auto" (
    set AUTO_MODE=1
    call :push_all
    goto :eof
)

if "%~1"=="push-interactive" (
    set AUTO_MODE=0
    call :push_all
    goto :eof
)

if "%~1"=="pull-main" (
    call :pull_main_only
    goto :eof
)

if "%~1"=="push-main" (
    call :push_main_only
    goto :eof
)

if "%~1"=="pull-subs" (
    call :pull_submodules_only
    goto :eof
)

if "%~1"=="push-subs" (
    call :push_submodules_only
    goto :eof
)

if "%~1"=="status" (
    call :check_status
    goto :eof
)

if "%~1"=="sync" (
    call :sync_all
    goto :eof
)

echo [ERROR] Unknown command: %~1
call :show_help
goto :eof

:show_help
echo Usage: git-manage.bat [command]
echo.
echo Available commands:
echo   pull            - Pull main repository and all submodules
echo   push            - Push main repository and all submodules (auto mode)
echo   push-auto       - Push with automatic commit messages (no interaction)
echo   push-interactive- Push with interactive commit message input
echo   pull-main       - Pull main repository only
echo   push-main       - Push main repository only
echo   pull-subs       - Pull all submodules only
echo   push-subs       - Push all submodules only
echo   status          - Check status of main repository and submodules
echo   sync            - Sync all repositories to latest state
echo   help            - Show this help information
echo.
echo Examples:
echo   git-manage.bat pull           # Pull all repositories
echo   git-manage.bat push           # Push all (auto mode, no prompts)
echo   git-manage.bat push-auto      # Push all (auto mode, no prompts)
echo   git-manage.bat push-interactive # Push all (with commit message prompts)
echo   git-manage.bat status         # Check status
echo.
echo Note: Default 'push' command now runs in auto mode for one-step operation
echo.
goto :eof

:pull_all
echo [INFO] Starting to pull main repository and all submodules...
echo.

call :pull_main_only
if errorlevel 1 (
    echo [ERROR] Main repository pull failed
    goto :eof
)

call :pull_submodules_only
if errorlevel 1 (
    echo [ERROR] Submodules pull failed
    goto :eof
)

echo.
echo [SUCCESS] All repositories pulled successfully!
goto :eof

:push_all
echo [INFO] Starting to push main repository and all submodules...
echo.

call :push_submodules_only
if errorlevel 1 (
    echo [ERROR] Submodules push failed
    goto :eof
)

call :push_main_only
if errorlevel 1 (
    echo [ERROR] Main repository push failed
    goto :eof
)

echo.
echo [SUCCESS] All repositories pushed successfully!
goto :eof

:pull_main_only
echo [INFO] Pulling main repository...
git fetch origin
if errorlevel 1 (
    echo [ERROR] Failed to fetch remote updates
    exit /b 1
)

git pull origin main
if errorlevel 1 (
    echo [ERROR] Failed to pull main repository
    exit /b 1
)

echo [SUCCESS] Main repository pulled successfully
goto :eof

:push_main_only
echo [INFO] Pushing main repository...

:: First, add all files (including new untracked files)
echo [INFO] Adding all files (including new files)...
git add .
if errorlevel 1 (
    echo [ERROR] Failed to add files
    exit /b 1
)

:: Check for changes after adding
for /f %%i in ('git status --porcelain 2^>nul ^| find /c /v ""') do set changes=%%i

if !changes! gtr 0 (
    echo [INFO] Detected changes to commit...
    
    if "!AUTO_MODE!"=="0" (
        :: Interactive mode - ask for commit message
        set /p commit_msg="Enter commit message (press Enter for default): "
        if "!commit_msg!"=="" set commit_msg=Auto commit from git-manage script
    ) else (
        :: Auto mode - generate automatic commit message
        set commit_msg=Auto commit from git-manage script - %date% %time%
    )
    
    echo [INFO] Committing with message: !commit_msg!
    git commit -m "!commit_msg!"
    if errorlevel 1 (
        echo [ERROR] Commit failed
        exit /b 1
    )
    echo [SUCCESS] Changes committed successfully
) else (
    echo [INFO] No changes to commit
)

git push origin main
if errorlevel 1 (
    echo [ERROR] Failed to push main repository
    exit /b 1
)

echo [SUCCESS] Main repository pushed successfully
goto :eof

:pull_submodules_only
echo [INFO] Pulling all submodules...

git submodule update --init --recursive --remote
if errorlevel 1 (
    echo [ERROR] Submodule update failed
    exit /b 1
)

echo [SUCCESS] All submodules pulled successfully
goto :eof

:push_submodules_only
echo [INFO] Pushing all submodules...

:: Get all submodule paths
for /f "tokens=2" %%i in ('git submodule status 2^>nul') do (
    set submodule_path=%%i
    call :push_single_submodule "!submodule_path!"
)

echo [SUCCESS] All submodules pushed successfully
goto :eof

:push_single_submodule
set "sub_path=%~1"
if not exist "%sub_path%" (
    echo [WARNING] Submodule directory does not exist: %sub_path%
    goto :eof
)

echo [INFO] Processing submodule: %sub_path%
pushd "%sub_path%"

:: Add all files first (including new untracked files)
git add .
if errorlevel 1 (
    echo [WARNING] Failed to add files in submodule %sub_path%
    popd
    goto :eof
)

:: Check for changes after adding
for /f %%i in ('git status --porcelain 2^>nul ^| find /c /v ""') do set sub_changes=%%i

if !sub_changes! gtr 0 (
    echo [INFO] Submodule %sub_path% has changes, committing...
    
    if "!AUTO_MODE!"=="0" (
        :: Interactive mode - ask for commit message
        set /p sub_commit_msg="Enter commit message for submodule %sub_path% (press Enter for default): "
        if "!sub_commit_msg!"=="" set sub_commit_msg=Auto commit from git-manage script
    ) else (
        :: Auto mode - generate automatic commit message
        set sub_commit_msg=Auto commit from git-manage script - %date% %time%
    )
    
    echo [INFO] Committing submodule with message: !sub_commit_msg!
    git commit -m "!sub_commit_msg!"
    if errorlevel 1 (
        echo [ERROR] Submodule %sub_path% commit failed
        popd
        exit /b 1
    )
    
    :: Get current branch
    for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set current_branch=%%b
    if "!current_branch!"=="" set current_branch=main
    
    git push origin !current_branch!
    if errorlevel 1 (
        echo [ERROR] Submodule %sub_path% push failed
        popd
        exit /b 1
    )
    
    echo [SUCCESS] Submodule %sub_path% pushed successfully
) else (
    echo [INFO] Submodule %sub_path% has no changes
)

popd
goto :eof

:check_status
echo [INFO] Checking main repository and submodules status...
echo.

echo === Main Repository Status ===
git status --short
echo.

echo === Submodules Status ===
git submodule status
echo.

echo === Submodules Detailed Status ===
for /f "tokens=2" %%i in ('git submodule status 2^>nul') do (
    set submodule_path=%%i
    if exist "!submodule_path!" (
        echo.
        echo --- Submodule: !submodule_path! ---
        pushd "!submodule_path!"
        git status --short
        popd
    )
)

goto :eof

:sync_all
echo [INFO] Syncing all repositories to latest state...
echo.

call :pull_all
if errorlevel 1 (
    echo [ERROR] Sync failed
    goto :eof
)

echo [INFO] Updating submodule references...
git add .gitmodules
for /f "tokens=2" %%i in ('git submodule status 2^>nul') do (
    git add "%%i"
)

for /f %%i in ('git status --porcelain 2^>nul ^| find /c /v ""') do set sync_changes=%%i
if !sync_changes! gtr 0 (
    git commit -m "Update submodule references"
    git push origin main
    echo [SUCCESS] Submodule references updated and pushed
) else (
    echo [INFO] Submodule references do not need updating
)

echo.
echo [SUCCESS] All repositories synced successfully!
goto :eof