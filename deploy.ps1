# VSS 项目部署脚本 (PowerShell)
# 使用 Nginx 反向代理简化端口管理

Write-Host "=== VSS 项目 Nginx 代理部署 ===" -ForegroundColor Green

# 检查配置文件
if (-not (Test-Path ".env")) {
    Write-Host "❌ 缺少 .env 配置文件" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "nginx.conf")) {
    Write-Host "❌ 缺少 nginx.conf 配置文件" -ForegroundColor Red
    exit 1
}

# 读取环境变量
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        $name = $matches[1]
        $value = $matches[2]
        [System.Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

$nginxPort = $env:NGINX_PORT ?? "80"
$devToolsPort = $env:NGINX_DEV_TOOLS_PORT ?? "8080"  
$adminPort = $env:NGINX_ADMIN_PORT ?? "8081"
$dockerNetwork = $env:DOCKER_NETWORK ?? "vss-network"

Write-Host "📋 当前配置：" -ForegroundColor Yellow
Write-Host "   - Nginx 主端口: $nginxPort"
Write-Host "   - 开发工具端口: $devToolsPort"
Write-Host "   - 管理工具端口: $adminPort"
Write-Host "   - 网络名称: $dockerNetwork"

# 停止现有容器
Write-Host "🛑 停止现有容器..." -ForegroundColor Yellow
docker-compose down

# 清理无用镜像
Write-Host "🧹 清理无用镜像..." -ForegroundColor Yellow
docker image prune -f

# 构建并启动服务
Write-Host "🚀 启动 VSS 平台服务..." -ForegroundColor Green
docker-compose up -d --build

# 等待服务启动
Write-Host "⏳ 等待服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 检查服务状态
Write-Host "📊 检查服务状态：" -ForegroundColor Yellow
docker-compose ps

# 显示访问地址
Write-Host ""
Write-Host "✅ VSS 平台已启动！" -ForegroundColor Green
Write-Host "🌐 访问地址：" -ForegroundColor Cyan
Write-Host "   - 主应用: http://localhost:$nginxPort"
Write-Host "   - 邮件测试: http://localhost:$devToolsPort"
Write-Host "   - 数据库管理: http://localhost:$adminPort"
Write-Host ""
Write-Host "📝 查看日志: docker-compose logs -f" -ForegroundColor Gray
Write-Host "🛑 停止服务: docker-compose down" -ForegroundColor Gray
