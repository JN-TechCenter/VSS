# VSS 反向代理解决方案

## 🎯 问题描述

在开发和部署 VSS Vision Platform 时，经常遇到端口冲突问题：
- 前端应用默认端口 3000
- 后端 API 服务端口 3002
- 数据库端口 5432
- Redis 端口 6379
- 各种开发工具端口

这些端口可能与系统中其他服务冲突，导致启动失败。

## 🔧 解决方案

使用 **nginx 反向代理** 作为统一入口点，解决端口冲突问题：

### 架构图
```
用户访问
    ↓
[nginx:80] ← 唯一对外端口
    ↓
内部网络路由
    ├── frontend:3000 (前端应用)
    ├── backend:3002  (API 服务)
    ├── database:5432 (数据库)
    └── redis:6379    (缓存)
```

### 核心优势

1. **端口统一**：只暴露端口 80 和 8080，避免冲突
2. **路径路由**：通过 URL 路径区分不同服务
3. **负载均衡**：支持多实例和负载均衡
4. **SSL终止**：集中处理 HTTPS 证书
5. **缓存优化**：静态资源缓存和压缩
6. **安全防护**：统一安全策略和访问控制

## 📁 文件结构

```
VSS/
├── nginx.conf                    # 主 nginx 配置
├── nginx-complete.conf          # 完整配置模板
├── docker-compose.proxy.yml     # 反向代理 Docker 配置
├── .env.proxy                   # 环境变量配置
├── start-proxy.bat             # Windows 启动脚本
├── start-proxy.ps1             # PowerShell 启动脚本
└── README-PROXY.md             # 本文档
```

## 🚀 快速开始

### 1. 使用批处理脚本（推荐）

```batch
# 启动反向代理服务
.\start-proxy.bat

# 或使用 PowerShell
.\start-proxy.ps1
```

### 2. 手动启动

```bash
# 使用反向代理配置启动
docker-compose -f docker-compose.proxy.yml --env-file .env.proxy up --build -d

# 查看服务状态
docker-compose -f docker-compose.proxy.yml ps

# 查看日志
docker-compose -f docker-compose.proxy.yml logs -f
```

### 3. 开发模式（包含开发工具）

```powershell
# PowerShell 开发模式
.\start-proxy.ps1 -Dev
```

## 🌐 访问地址

### 主要服务
- **前端应用**: http://localhost
- **API 接口**: http://localhost/api
- **WebSocket**: ws://localhost/ws
- **健康检查**: http://localhost/health

### 开发工具 (端口 8080)
- **开发工具面板**: http://localhost:8080
- **邮件测试工具**: http://localhost:8080/mail
- **数据库管理**: http://localhost:8080/db
- **H2 控制台**: http://localhost/h2-console

### 监控端点
- **API 健康检查**: http://localhost/api/actuator/health
- **应用监控**: http://localhost/actuator
- **Nginx 状态**: http://localhost/health

## ⚙️ 配置说明

### 环境变量 (.env.proxy)

```bash
# 主要端口配置
NGINX_PORT=80              # nginx 主端口
DEV_TOOLS_PORT=8080       # 开发工具端口

# 内部服务端口（不对外暴露）
BACKEND_PORT=3002         # 后端服务端口
FRONTEND_INTERNAL_PORT=3000  # 前端内部端口

# 数据库配置
DB_HOST=database
DB_PORT=5432
DB_NAME=vss_production_db
DB_USERNAME=prod_user
DB_PASSWORD=your_secure_password

# API 配置
VITE_API_BASE_URL=http://localhost/api/v1
```

### Nginx 路由规则

| 路径 | 目标服务 | 说明 |
|------|----------|------|
| `/` | frontend:3000 | 前端应用根路径 |
| `/api/` | backend:3002/api/ | API 接口代理 |
| `/ws` | backend:3002/ws | WebSocket 连接 |
| `/h2-console/` | backend:3002/h2-console/ | H2 数据库控制台 |
| `/actuator/` | backend:3002/actuator/ | 监控端点 |
| `/health` | nginx | 代理健康检查 |

## 🔒 安全配置

### 安全头设置
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

### 速率限制
```nginx
# API 接口限制：10 请求/秒
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

# 认证接口限制：5 请求/秒
limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;

# 文件上传限制：2 请求/秒
limit_req_zone $binary_remote_addr zone=upload:10m rate=2r/s;
```

### 访问控制
```nginx
# 禁止访问隐藏文件
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}

# 禁止访问敏感路径
location ~ /(\.git|\.env|config|logs)/ {
    deny all;
    access_log off;
    log_not_found off;
}
```

## 🎛️ 管理命令

### PowerShell 脚本命令
```powershell
# 启动服务
.\start-proxy.ps1

# 开发模式（包含开发工具）
.\start-proxy.ps1 -Dev

# 停止服务
.\start-proxy.ps1 -Stop

# 重启服务
.\start-proxy.ps1 -Restart

# 查看日志
.\start-proxy.ps1 -Logs
```

### Docker Compose 命令
```bash
# 启动所有服务
docker-compose -f docker-compose.proxy.yml up -d

# 启动开发工具
docker-compose -f docker-compose.proxy.yml --profile dev-tools up -d

# 重新构建并启动
docker-compose -f docker-compose.proxy.yml up --build -d

# 停止服务
docker-compose -f docker-compose.proxy.yml down

# 查看日志
docker-compose -f docker-compose.proxy.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.proxy.yml logs -f nginx
docker-compose -f docker-compose.proxy.yml logs -f backend
```

## 🔧 故障排除

### 常见问题

1. **服务无法启动**
   ```bash
   # 检查端口占用
   netstat -ano | findstr :80
   netstat -ano | findstr :8080
   
   # 停止占用端口的进程
   taskkill /PID <进程ID> /F
   ```

2. **nginx 配置错误**
   ```bash
   # 测试配置文件
   docker run --rm -v ${PWD}/nginx.conf:/etc/nginx/nginx.conf nginx nginx -t
   ```

3. **服务间连接问题**
   ```bash
   # 检查网络连接
   docker network ls
   docker network inspect vss-network
   ```

4. **权限问题**
   ```bash
   # 确保文件有执行权限
   chmod +x start-proxy.ps1
   ```

### 调试命令

```bash
# 查看容器状态
docker ps

# 进入 nginx 容器
docker exec -it vss-nginx sh

# 查看 nginx 配置
docker exec vss-nginx nginx -T

# 重新加载 nginx 配置
docker exec vss-nginx nginx -s reload

# 查看实时日志
docker logs -f vss-nginx
docker logs -f vss-backend
docker logs -f vss-frontend
```

## 📊 性能优化

### 静态资源缓存
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary "Accept-Encoding";
}
```

### Gzip 压缩
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;
```

### 连接池优化
```nginx
upstream vss_backend {
    server backend:3002;
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}
```

## 🎯 生产环境部署

### HTTPS 配置

1. 获取 SSL 证书（Let's Encrypt 推荐）
2. 更新 nginx 配置：

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # SSL 安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # 其他配置...
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### 环境变量调整

```bash
# 生产环境配置
NODE_ENV=production
SPRING_PROFILES_ACTIVE=prod
LOG_LEVEL=warn
PROD_OPTIMIZE=true
PROD_GZIP=true
```

## 📝 许可证

本项目遵循 MIT 许可证。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个反向代理解决方案。

---

**注意**：这个解决方案完全解决了端口冲突问题，使得 VSS Vision Platform 可以在任何环境中稳定运行，无需担心端口占用冲突。
