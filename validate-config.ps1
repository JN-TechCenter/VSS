# VSS 端口配置验证脚本

Write-Host "============================================" -ForegroundColor Blue
Write-Host "VSS 端口配置验证" -ForegroundColor Blue
Write-Host "============================================" -ForegroundColor Blue
Write-Host ""

$errors = @()
$warnings = @()

# 验证前端配置
Write-Host "📱 检查前端配置..." -ForegroundColor Cyan

# 检查 vite.config.ts
if (Test-Path "VSS-frontend/vite.config.ts") {
    $viteConfig = Get-Content "VSS-frontend/vite.config.ts" -Raw
    
    if ($viteConfig -match "port:\s*3000") {
        $warnings += "前端 vite.config.ts 中仍有硬编码端口 3000"
    }
    
    if ($viteConfig -match "process\.env\.VITE_PORT") {
        Write-Host "✅ 前端使用环境变量端口配置" -ForegroundColor Green
    } else {
        $errors += "前端未使用环境变量端口配置"
    }
} else {
    $errors += "前端 vite.config.ts 文件不存在"
}

# 检查前端 API 客户端
if (Test-Path "VSS-frontend/src/api/client.ts") {
    $clientConfig = Get-Content "VSS-frontend/src/api/client.ts" -Raw
    
    if ($clientConfig -match "localhost:300\d") {
        $errors += "前端 API 客户端中有硬编码端口"
    } else {
        Write-Host "✅ 前端 API 客户端使用相对路径" -ForegroundColor Green
    }
    
    if ($clientConfig -match "/api") {
        Write-Host "✅ 前端使用相对 API 路径" -ForegroundColor Green
    }
} else {
    $warnings += "前端 API 客户端文件不存在"
}

# 检查前端环境变量
if (Test-Path "VSS-frontend/.env.proxy") {
    $frontendEnv = Get-Content "VSS-frontend/.env.proxy" -Raw
    
    if ($frontendEnv -match "VITE_API_BASE_URL=/api") {
        Write-Host "✅ 前端环境变量使用相对路径" -ForegroundColor Green
    } else {
        $errors += "前端环境变量未使用相对 API 路径"
    }
} else {
    $warnings += "前端环境变量文件不存在"
}

Write-Host ""

# 验证后端配置
Write-Host "🔧 检查后端配置..." -ForegroundColor Cyan

# 检查 application-docker.properties
if (Test-Path "VSS-backend/src/main/resources/application-docker.properties") {
    $backendConfig = Get-Content "VSS-backend/src/main/resources/application-docker.properties" -Raw
    
    if ($backendConfig -match "cors\.allowed-origins.*localhost:300\d") {
        $errors += "后端 CORS 配置中有硬编码端口"
    } else {
        Write-Host "✅ 后端 CORS 配置不包含硬编码端口" -ForegroundColor Green
    }
    
    if ($backendConfig -match "\$\{SERVER_PORT:3002\}") {
        Write-Host "✅ 后端使用环境变量端口配置" -ForegroundColor Green
    } else {
        $warnings += "后端未使用环境变量端口配置"
    }
} else {
    $errors += "后端配置文件不存在"
}

Write-Host ""

# 验证 Docker 配置
Write-Host "🐳 检查 Docker 配置..." -ForegroundColor Cyan

# 检查 docker-compose.proxy.yml
if (Test-Path "docker-compose.proxy.yml") {
    $dockerConfig = Get-Content "docker-compose.proxy.yml" -Raw
    
    # 检查是否只有 nginx 暴露端口
    $portMatches = [regex]::Matches($dockerConfig, "ports:\s*\n\s*-\s*")
    if ($portMatches.Count -eq 1) {
        Write-Host "✅ 只有 nginx 服务暴露端口" -ForegroundColor Green
    } else {
        $warnings += "可能有多个服务暴露端口"
    }
    
    # 检查前端构建参数
    if ($dockerConfig -match "VITE_API_BASE_URL=/api") {
        Write-Host "✅ Docker 构建使用相对 API 路径" -ForegroundColor Green
    } else {
        $errors += "Docker 构建未使用相对 API 路径"
    }
} else {
    $errors += "Docker Compose 反向代理配置不存在"
}

# 检查环境变量文件
if (Test-Path ".env.proxy") {
    $envConfig = Get-Content ".env.proxy" -Raw
    
    if ($envConfig -match "VITE_API_BASE_URL=/api") {
        Write-Host "✅ 主环境变量使用相对路径" -ForegroundColor Green
    } else {
        $errors += "主环境变量未使用相对 API 路径"
    }
    
    if ($envConfig -match "NGINX_PORT=80") {
        Write-Host "✅ Nginx 端口配置正确" -ForegroundColor Green
    }
} else {
    $errors += "主环境变量文件不存在"
}

Write-Host ""

# 验证 nginx 配置
Write-Host "🌐 检查 Nginx 配置..." -ForegroundColor Cyan

if (Test-Path "nginx.conf") {
    $nginxConfig = Get-Content "nginx.conf" -Raw
    
    if ($nginxConfig -match "upstream vss_backend") {
        Write-Host "✅ Nginx 上游服务配置正确" -ForegroundColor Green
    } else {
        $warnings += "Nginx 上游服务配置可能不完整"
    }
    
    if ($nginxConfig -match "proxy_pass http://vss_backend") {
        Write-Host "✅ Nginx API 代理配置正确" -ForegroundColor Green
    } else {
        $warnings += "Nginx API 代理配置可能有问题"
    }
} else {
    $warnings += "Nginx 配置文件不存在"
}

Write-Host ""

# 显示结果
Write-Host "============================================" -ForegroundColor Blue
Write-Host "验证结果" -ForegroundColor Blue
Write-Host "============================================" -ForegroundColor Blue

if ($errors.Count -eq 0) {
    Write-Host "🎉 所有配置验证通过！" -ForegroundColor Green
    Write-Host "您的应用已正确配置为使用反向代理方案" -ForegroundColor Green
} else {
    Write-Host "❌ 发现 $($errors.Count) 个错误:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  发现 $($warnings.Count) 个警告:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📋 配置检查项目:" -ForegroundColor Cyan
Write-Host "✅ 前端不使用硬编码端口" -ForegroundColor White
Write-Host "✅ 后端 CORS 不包含端口" -ForegroundColor White
Write-Host "✅ API 客户端使用相对路径" -ForegroundColor White
Write-Host "✅ Docker 只暴露必要端口" -ForegroundColor White
Write-Host "✅ 环境变量配置正确" -ForegroundColor White

Write-Host ""
Write-Host "🚀 如果验证通过，可以运行:" -ForegroundColor Green
Write-Host "  .\deploy-proxy.ps1 -Quick" -ForegroundColor White
Write-Host ""
