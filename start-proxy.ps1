# VSS 反向代理启动脚本 - PowerShell 版本
# 解决端口冲突问题，使用 nginx 统一代理所有服务

param(
    [switch]$Dev,
    [switch]$Prod,
    [switch]$Stop,
    [switch]$Restart,
    [switch]$Logs
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ColorOutput($ForegroundColor) {
    if ($Host.UI.RawUI.ForegroundColor) {
        $fc = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = $ForegroundColor
        if ($args) {
            Write-Output $args
        } else {
            $input | Write-Output
        }
        $Host.UI.RawUI.ForegroundColor = $fc
    } else {
        if ($args) {
            Write-Output $args
        } else {
            $input | Write-Output
        }
    }
}

function Write-Info($Message) {
    Write-ColorOutput -ForegroundColor Cyan "[信息] $Message"
}

function Write-Success($Message) {
    Write-ColorOutput -ForegroundColor Green "[成功] $Message"
}

function Write-Warning($Message) {
    Write-ColorOutput -ForegroundColor Yellow "[警告] $Message"
}

function Write-Error($Message) {
    Write-ColorOutput -ForegroundColor Red "[错误] $Message"
}

# 显示标题
Write-Host "============================================" -ForegroundColor Blue
Write-Host "VSS Vision Platform - 反向代理管理脚本" -ForegroundColor Blue
Write-Host "============================================" -ForegroundColor Blue
Write-Host ""

# 检查 Docker
try {
    docker version | Out-Null
    Write-Success "Docker 运行正常"
} catch {
    Write-Error "Docker 未运行，请先启动 Docker Desktop"
    exit 1
}

# 设置配置文件
$envFile = ".env.proxy"
$composeFile = "docker-compose.proxy.yml"

if (-not (Test-Path $envFile)) {
    Write-Warning "环境配置文件 $envFile 不存在"
    Write-Info "将使用默认配置，建议创建 $envFile 文件进行自定义配置"
}

# 处理命令行参数
if ($Stop) {
    Write-Info "停止 VSS 反向代理服务..."
    docker-compose -f $composeFile --env-file $envFile down
    Write-Success "服务已停止"
    exit 0
}

if ($Logs) {
    Write-Info "显示服务日志..."
    docker-compose -f $composeFile --env-file $envFile logs -f
    exit 0
}

if ($Restart) {
    Write-Info "重启 VSS 反向代理服务..."
    docker-compose -f $composeFile --env-file $envFile restart
    Write-Success "服务已重启"
    exit 0
}

# 选择运行模式
$profiles = @()
if ($Dev) {
    $profiles += "dev-tools"
    Write-Info "启用开发工具模式"
}

if ($Prod) {
    Write-Info "生产环境模式"
}

# 停止现有服务
Write-Info "停止现有服务..."
docker-compose -f $composeFile --env-file $envFile down 2>$null

# 构建参数
$buildArgs = @(
    "-f", $composeFile,
    "--env-file", $envFile
)

if ($profiles.Count -gt 0) {
    foreach ($profile in $profiles) {
        $buildArgs += "--profile"
        $buildArgs += $profile
    }
}

$buildArgs += "up", "--build", "-d"

# 启动服务
Write-Info "构建并启动反向代理服务..."
Write-Host ""
Write-Info "主要访问地址:"
Write-Host "  🎨 前端应用:    http://localhost" -ForegroundColor Green
Write-Host "  🔧 API 接口:    http://localhost/api" -ForegroundColor Green
Write-Host "  🛠️  开发工具:    http://localhost:8080" -ForegroundColor Green
Write-Host "  ❤️  健康检查:    http://localhost/health" -ForegroundColor Green
Write-Host ""

try {
    & docker-compose @buildArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose 命令失败"
    }
} catch {
    Write-Error "服务启动失败: $_"
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "🎉 VSS 反向代理服务启动成功!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# 显示服务状态
Write-Info "服务状态:"
docker-compose -f $composeFile --env-file $envFile ps

Write-Host ""
Write-Info "管理命令:"
Write-Host "  查看日志: .\start-proxy.ps1 -Logs" -ForegroundColor Cyan
Write-Host "  停止服务: .\start-proxy.ps1 -Stop" -ForegroundColor Cyan
Write-Host "  重启服务: .\start-proxy.ps1 -Restart" -ForegroundColor Cyan
Write-Host "  开发模式: .\start-proxy.ps1 -Dev" -ForegroundColor Cyan
Write-Host ""

# 等待服务启动
Write-Info "等待服务完全启动..."
Start-Sleep -Seconds 5

# 健康检查
Write-Info "执行健康检查..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost/health" -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Success "✅ 服务健康检查通过"
    } else {
        Write-Warning "⚠️  服务响应异常，状态码: $($response.StatusCode)"
    }
} catch {
    Write-Warning "⚠️  服务可能还在启动中，请稍等片刻再访问"
}

Write-Host ""
Write-Host "💡 端口冲突解决方案:" -ForegroundColor Yellow
Write-Host "   - 所有服务通过 nginx 统一代理" -ForegroundColor Yellow
Write-Host "   - 只暴露端口 80 (主服务) 和 8080 (开发工具)" -ForegroundColor Yellow
Write-Host "   - 内部服务端口不对外暴露，避免冲突" -ForegroundColor Yellow
Write-Host ""
