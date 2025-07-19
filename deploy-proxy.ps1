# VSS 反向代理快速部署脚本

param(
    [switch]$Quick,      # 快速部署（使用默认配置）
    [switch]$Interactive, # 交互式配置
    [switch]$Help        # 显示帮助
)

if ($Help) {
    Write-Host @"
VSS 反向代理快速部署脚本

用法:
  .\deploy-proxy.ps1 [-Quick] [-Interactive] [-Help]

参数:
  -Quick       快速部署，使用默认配置
  -Interactive 交互式配置部署
  -Help        显示此帮助信息

示例:
  .\deploy-proxy.ps1 -Quick
  .\deploy-proxy.ps1 -Interactive

"@ -ForegroundColor Cyan
    exit 0
}

# 设置错误处理
$ErrorActionPreference = "Stop"

# 显示欢迎信息
Write-Host @"
============================================
🚀 VSS 反向代理快速部署
============================================
解决端口冲突问题的一站式部署方案
"@ -ForegroundColor Blue

# 检查前置条件
Write-Host "`n📋 检查前置条件..." -ForegroundColor Yellow

# 检查 Docker
try {
    docker version | Out-Null
    Write-Host "✅ Docker 运行正常" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker 未运行，请先启动 Docker Desktop" -ForegroundColor Red
    exit 1
}

# 检查 Docker Compose
try {
    docker-compose version | Out-Null
    Write-Host "✅ Docker Compose 可用" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose 不可用" -ForegroundColor Red
    exit 1
}

# 检查端口占用
$ports = @(80, 8080)
foreach ($port in $ports) {
    $connections = netstat -ano | Select-String ":$port "
    if ($connections) {
        Write-Host "⚠️  端口 $port 被占用，部署后可能需要停止占用进程" -ForegroundColor Yellow
    } else {
        Write-Host "✅ 端口 $port 可用" -ForegroundColor Green
    }
}

Write-Host "`n📁 准备配置文件..." -ForegroundColor Yellow

# 检查环境配置文件
if (-not (Test-Path ".env.proxy")) {
    if (Test-Path ".env.proxy.example") {
        Write-Host "📄 复制示例配置文件..." -ForegroundColor Cyan
        Copy-Item ".env.proxy.example" ".env.proxy"
        Write-Host "✅ 已创建 .env.proxy 配置文件" -ForegroundColor Green
    } else {
        Write-Host "❌ 找不到配置文件模板" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ 配置文件 .env.proxy 已存在" -ForegroundColor Green
}

# 交互式配置
if ($Interactive) {
    Write-Host "`n⚙️  交互式配置..." -ForegroundColor Yellow
    
    # 应用名称
    $appName = Read-Host "应用名称 (默认: vss)"
    if ($appName) {
        (Get-Content ".env.proxy") -replace "APP_NAME=.*", "APP_NAME=$appName" | Set-Content ".env.proxy"
    }
    
    # 主端口
    $mainPort = Read-Host "主服务端口 (默认: 80)"
    if ($mainPort -and $mainPort -ne "80") {
        (Get-Content ".env.proxy") -replace "NGINX_PORT=.*", "NGINX_PORT=$mainPort" | Set-Content ".env.proxy"
    }
    
    # 开发工具端口
    $devPort = Read-Host "开发工具端口 (默认: 8080)"
    if ($devPort -and $devPort -ne "8080") {
        (Get-Content ".env.proxy") -replace "DEV_TOOLS_PORT=.*", "DEV_TOOLS_PORT=$devPort" | Set-Content ".env.proxy"
    }
    
    # 数据库密码
    $dbPassword = Read-Host "数据库密码 (留空保持默认)"
    if ($dbPassword) {
        (Get-Content ".env.proxy") -replace "DB_PASSWORD=.*", "DB_PASSWORD=$dbPassword" | Set-Content ".env.proxy"
    }
    
    # JWT 密钥
    $jwtSecret = Read-Host "JWT 密钥 (留空自动生成)"
    if (-not $jwtSecret) {
        $jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
        Write-Host "🔑 已生成 JWT 密钥: $($jwtSecret.Substring(0,8))..." -ForegroundColor Green
    }
    (Get-Content ".env.proxy") -replace "JWT_SECRET=.*", "JWT_SECRET=$jwtSecret" | Set-Content ".env.proxy"
}

# 快速配置（生成安全密钥）
if ($Quick -or -not $Interactive) {
    Write-Host "`n🔧 快速配置..." -ForegroundColor Yellow
    
    # 生成安全的 JWT 密钥
    $jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    (Get-Content ".env.proxy") -replace "JWT_SECRET=请_生成_并_设置_强_JWT_密钥_至少32字符长度", "JWT_SECRET=$jwtSecret" | Set-Content ".env.proxy"
    
    # 生成数据库密码
    $dbPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    (Get-Content ".env.proxy") -replace "DB_PASSWORD=请_修改_为_安全_密码", "DB_PASSWORD=$dbPassword" | Set-Content ".env.proxy"
    
    # 生成 Redis 密码
    $redisPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    (Get-Content ".env.proxy") -replace "REDIS_PASSWORD=请_修改_为_安全_Redis_密码", "REDIS_PASSWORD=$redisPassword" | Set-Content ".env.proxy"
    
    Write-Host "✅ 已生成安全配置" -ForegroundColor Green
}

# 显示部署信息
Write-Host "`n🚀 开始部署..." -ForegroundColor Yellow

# 停止现有服务
Write-Host "🛑 停止现有服务..." -ForegroundColor Cyan
docker-compose -f docker-compose.proxy.yml down 2>$null

# 构建并启动服务
Write-Host "🔨 构建并启动服务..." -ForegroundColor Cyan
Write-Host ""

try {
    docker-compose -f docker-compose.proxy.yml --env-file .env.proxy up --build -d
    if ($LASTEXITCODE -ne 0) {
        throw "部署失败"
    }
} catch {
    Write-Host "❌ 部署失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "🎉 VSS 反向代理部署成功！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# 等待服务启动
Write-Host "`n⏳ 等待服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 显示服务状态
Write-Host "`n📊 服务状态:" -ForegroundColor Cyan
docker-compose -f docker-compose.proxy.yml ps

# 健康检查
Write-Host "`n🔍 健康检查..." -ForegroundColor Yellow
$healthChecks = @(
    @{ Name = "前端应用"; Url = "http://localhost" }
    @{ Name = "API 服务"; Url = "http://localhost/api/actuator/health" }
    @{ Name = "代理服务"; Url = "http://localhost/health" }
    @{ Name = "开发工具"; Url = "http://localhost:8080" }
)

foreach ($check in $healthChecks) {
    try {
        $response = Invoke-WebRequest -Uri $check.Url -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($check.Name) 运行正常" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $($check.Name) 响应异常 (状态码: $($response.StatusCode))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($check.Name) 连接失败" -ForegroundColor Red
    }
}

# 显示访问信息
Write-Host "`n🌐 访问地址:" -ForegroundColor Cyan
Write-Host "  🎨 前端应用:    http://localhost" -ForegroundColor White
Write-Host "  🔧 API 接口:    http://localhost/api" -ForegroundColor White
Write-Host "  🛠️  开发工具:    http://localhost:8080" -ForegroundColor White
Write-Host "  ❤️  健康检查:    http://localhost/health" -ForegroundColor White

# 显示管理命令
Write-Host "`n💡 管理命令:" -ForegroundColor Cyan
Write-Host "  启动服务:  .\start-proxy.ps1" -ForegroundColor White
Write-Host "  停止服务:  .\start-proxy.ps1 -Stop" -ForegroundColor White
Write-Host "  查看日志:  .\start-proxy.ps1 -Logs" -ForegroundColor White
Write-Host "  连接测试:  .\test-proxy.bat" -ForegroundColor White

# 显示重要提示
Write-Host "`n⚠️  重要提示:" -ForegroundColor Yellow
Write-Host "  - 配置文件已保存在 .env.proxy" -ForegroundColor White
Write-Host "  - 请妥善保管生成的密钥和密码" -ForegroundColor White
Write-Host "  - 生产环境请及时修改默认配置" -ForegroundColor White
Write-Host "  - 此方案完全解决了端口冲突问题" -ForegroundColor White

Write-Host "`n🎯 下一步:" -ForegroundColor Cyan
Write-Host "  1. 访问 http://localhost 查看前端应用" -ForegroundColor White
Write-Host "  2. 访问 http://localhost:8080 查看开发工具" -ForegroundColor White
Write-Host "  3. 运行 .\test-proxy.bat 测试所有连接" -ForegroundColor White

Write-Host "`n部署完成！按任意键退出..." -ForegroundColor Green
Read-Host
