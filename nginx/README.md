# Nginx 配置文件目录

> **Nginx 反向代理配置** - 统一管理所有 nginx 相关配置文件

## 📁 文件结构

```text
nginx/
├── README.md           # 本说明文档
├── nginx.conf          # 生产环境配置
├── nginx-dev.conf      # 开发环境配置 (支持HMR)
├── nginx-local.conf    # 本地开发配置
└── conf.d/            # 额外配置目录
```

## 🔧 配置文件说明

### 📄 `nginx.conf` - 生产环境配置

**用途**: Docker 生产环境的反向代理配置

**特点**:
- ✅ 静态文件服务优化
- ✅ 高性能缓存策略
- ✅ 安全头部配置
- ✅ 压缩和优化

**适用场景**: `.\docker-manage.bat proxy`

### 📄 `nginx-dev.conf` - 开发环境配置

**用途**: Docker 开发环境配置，支持热更新

**特点**:
- 🔥 WebSocket 代理支持 (HMR)
- 🔄 开发模式优化
- 📝 详细日志记录
- ⚡ 快速响应配置

**适用场景**: `.\docker-manage.bat dev-proxy`

### 📄 `nginx-local.conf` - 本地开发配置

**用途**: 本地开发环境的 nginx 配置

**特点**:
- 🏠 本地主机代理
- 🔧 开发调试优化
- 📊 端口 8080 服务
- 🎯 简化配置

**适用场景**: `setup-local-env.bat` 生成的本地环境

## 🚀 使用说明

### Docker 模式

Docker Compose 文件会自动映射对应的配置文件：

```yaml
# docker-compose.proxy.yml (生产)
nginx:
  volumes:
    - "./nginx/nginx.conf:/etc/nginx/nginx.conf"

# docker-compose.dev-proxy.yml (开发)  
nginx:
  volumes:
    - "./nginx/nginx-dev.conf:/etc/nginx/nginx.conf"
```

### 本地模式

本地安装脚本会使用 `nginx-local.conf`：

```bash
# setup-local-env.bat 会复制配置
copy nginx\nginx-local.conf C:\nginx\conf\nginx.conf
```

## 🔄 配置修改

### 修改端口配置

**生产环境** (`nginx.conf`):
```nginx
server {
    listen 80;
    # 修改监听端口
}
```

**开发环境** (`nginx-dev.conf`):
```nginx
upstream vss_frontend_dev {
    server frontend-dev:3000;  # 修改上游服务
}
```

### 添加新的路由

在对应配置文件中添加 `location` 块：

```nginx
location /new-api/ {
    proxy_pass http://vss_backend/new-api/;
    # 其他代理配置
}
```

## 🐛 故障排除

### 配置语法检查

```bash
# Docker 环境中检查
docker exec vss-nginx nginx -t

# 本地环境检查  
nginx -t -c nginx\nginx-local.conf
```

### 重载配置

```bash
# Docker 环境重载
docker exec vss-nginx nginx -s reload

# 或重启容器
docker restart vss-nginx
```

### 查看日志

```bash
# 查看 nginx 日志
docker logs vss-nginx -f

# 查看访问日志
docker exec vss-nginx tail -f /var/log/nginx/access.log
```

## 📝 维护指南

### 添加新配置文件

1. 在 `nginx/` 目录下创建新配置文件
2. 更新相应的 Docker Compose 文件
3. 更新本文档说明

### 版本控制

- ✅ 所有配置文件都应纳入版本控制
- ✅ 敏感配置使用环境变量替换
- ✅ 定期备份重要配置

---

*最后更新: 2025-07-20*
