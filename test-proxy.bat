@echo off
@REM VSS 反向代理测试脚本

echo ============================================
echo VSS 反向代理连接测试
echo ============================================
echo.

@REM 检查 curl 是否可用
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] curl 不可用，将使用 PowerShell 进行测试
    goto :powershell_test
)

echo [信息] 使用 curl 进行连接测试...
echo.

@REM 测试主页
echo [测试] 前端应用 (http://localhost)
curl -s -o nul -w "状态码: %%{http_code} | 响应时间: %%{time_total}s\n" http://localhost
if %errorlevel% equ 0 (
    echo ✅ 前端应用连接正常
) else (
    echo ❌ 前端应用连接失败
)
echo.

@REM 测试 API
echo [测试] API 健康检查 (http://localhost/api/actuator/health)
curl -s -o nul -w "状态码: %%{http_code} | 响应时间: %%{time_total}s\n" http://localhost/api/actuator/health
if %errorlevel% equ 0 (
    echo ✅ API 服务连接正常
) else (
    echo ❌ API 服务连接失败
)
echo.

@REM 测试代理健康检查
echo [测试] 代理健康检查 (http://localhost/health)
curl -s -o nul -w "状态码: %%{http_code} | 响应时间: %%{time_total}s\n" http://localhost/health
if %errorlevel% equ 0 (
    echo ✅ 代理服务连接正常
) else (
    echo ❌ 代理服务连接失败
)
echo.

@REM 测试开发工具
echo [测试] 开发工具面板 (http://localhost:8080)
curl -s -o nul -w "状态码: %%{http_code} | 响应时间: %%{time_total}s\n" http://localhost:8080
if %errorlevel% equ 0 (
    echo ✅ 开发工具连接正常
) else (
    echo ❌ 开发工具连接失败
)

goto :end

:powershell_test
echo [信息] 使用 PowerShell 进行连接测试...
powershell -Command "& {
    function Test-Url($url, $name) {
        try {
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing
            Write-Host \"✅ $name 连接正常 (状态码: $($response.StatusCode))\" -ForegroundColor Green
        } catch {
            Write-Host \"❌ $name 连接失败: $_\" -ForegroundColor Red
        }
    }
    
    Write-Host \"[测试] 前端应用\" -ForegroundColor Cyan
    Test-Url \"http://localhost\" \"前端应用\"
    
    Write-Host \"[测试] API 服务\" -ForegroundColor Cyan
    Test-Url \"http://localhost/api/actuator/health\" \"API 服务\"
    
    Write-Host \"[测试] 代理健康检查\" -ForegroundColor Cyan
    Test-Url \"http://localhost/health\" \"代理服务\"
    
    Write-Host \"[测试] 开发工具\" -ForegroundColor Cyan
    Test-Url \"http://localhost:8080\" \"开发工具\"
}"

:end
echo.
echo ============================================
echo 测试完成
echo ============================================
echo.
echo 💡 如果测试失败，请检查：
echo   1. 服务是否已启动 (运行 start-proxy.bat)
echo   2. Docker 是否正常运行
echo   3. 端口 80 和 8080 是否被占用
echo.
pause
