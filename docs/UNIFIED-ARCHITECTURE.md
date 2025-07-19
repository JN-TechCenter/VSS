# VSS 统一架构配置说明

## 🎯 架构统一目标
Docker 部署和本地部署现在使用完全一致的架构：
- **后端**: 内部端口 3000
- **前端**: 由 Nginx 代理静态文件服务
- **统一入口**: Nginx 反向代理 (Docker: 端口80，本地: 端口8080)

## 📋 配置变更总结

### 1. Docker 配置 (.env.proxy)
```bash
# 后端端口统一为 3000
BACKEND_PORT=3000
SERVER_PORT=3000

# 前端内部端口
FRONTEND_INTERNAL_PORT=80
```

### 2. Nginx 代理配置
- **Docker (nginx.conf)**: `backend:3000`
- **本地 (nginx-local.conf)**: `127.0.0.1:3000`

### 3. 本地开发环境
- 后端启动端口: 3000
- 前端开发服务器: 3000
- Nginx 本地代理: 8080

## 🚀 启动方式

### Docker 部署 (推荐)
```bash
# 使用代理模式启动
docker-manage.bat proxy

# 访问地址
http://localhost        # 主应用 (通过 Nginx 代理)
http://localhost:8080   # 开发工具端口
```

### 本地开发部署
```bash
# 安装环境
setup-local-env.bat

# 启动所有服务
start-all.bat

# 访问地址
http://localhost:8080   # 主应用 (通过 Nginx 代理)
http://localhost:3000   # 前端直连 (开发调试)
```

## 📊 端口映射表

| 服务 | Docker 容器端口 | 本地开发端口 | Nginx 代理 | 访问地址 |
|------|----------------|-------------|-----------|----------|
| 后端 | 3000 (内部) | 3000 | ✅ /api/ | http://localhost/api/ |
| 前端 | 80 (静态文件) | 3000 (开发) | ✅ / | http://localhost/ |
| Nginx | 80, 8080 | 8080 | - | http://localhost/ |

## ✅ 验证结果

### Docker 容器状态
```
CONTAINER   PORTS                                    STATUS
vss-nginx   0.0.0.0:80->80/tcp, 0.0.0.0:8080->8080/tcp   Up
vss-backend 3000/tcp (内部)                            Up 
vss-frontend 80/tcp (内部)                            Up
```

### 后端服务确认
```
SERVER_PORT=3000  ✅ 统一配置成功
```

## 🎉 架构优势

1. **端口统一**: Docker 和本地使用相同的后端端口 3000
2. **代理一致**: 都通过 Nginx 反向代理统一访问
3. **无端口冲突**: 只暴露必要的端口 (80, 8080)
4. **开发友好**: 本地可同时支持代理访问和直连调试
5. **生产就绪**: Docker 配置可直接用于生产环境

---

> 📅 更新时间: 2025-07-20  
> 🔧 配置状态: ✅ 已统一 Docker 和本地架构
