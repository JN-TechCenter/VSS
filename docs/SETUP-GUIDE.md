# VSS 项目完整配置与操作指南

> **版本**: v1.0 | **更新时间**: 2025-07-20  
> **适用环境**: Windows 10/11, Docker Desktop, Node.js 18+

## 📋 目录

1. [快速开始](#快速开始) - 5分钟快速上手
2. [环境配置文件说明](#环境配置文件说明) - 环境变量详解
3. [Docker 脚本详解](#docker-脚本详解) - 容器化部署
4. [本地开发指南](#本地开发指南) - 原生环境开发
5. [配置文件详解](#配置文件详解) - 深度配置解析
6. [日常操作手册](#日常操作手册) - 运维操作指南
7. [故障排除指南](#故障排除指南) - 问题诊断与解决

## 🚀 快速开始

### 三种部署模式选择

| 模式 | 适用场景 | 启动命令 | 访问地址 | 热更新 |
|------|----------|----------|----------|--------|
| **Docker 生产** | 生产部署、演示环境 | `.\docker-manage.bat proxy` | http://localhost | ❌ |
| **Docker 开发** | 团队开发、容器化开发 | `.\docker-manage.bat dev-proxy` | http://localhost | ✅ |
| **本地开发** | 个人开发、调试环境 | `setup-local-env.bat` → `start-all.bat` | http://localhost:8080 | ✅ |

### 30秒快速启动

```cmd
# 方式一：Docker 开发环境（推荐团队使用）
.\docker-manage.bat dev-proxy

# 方式二：本地开发环境（推荐个人使用）
setup-local-env.bat && start-all.bat

# 方式三：Docker 生产环境（推荐部署使用）
.\docker-manage.bat proxy
```

---

## 环境配置文件说明

### 📁 配置文件结构

```text
VSS/
├── .env.proxy              # Docker 生产代理配置 → config/.env.proxy
├── .env.dev-proxy          # Docker 开发代理配置 → config/.env.dev-proxy
├── config/                 # 配置文件目录
│   ├── README.md          # 配置文件说明
│   ├── .env               # 基础环境变量
│   ├── .env.proxy         # 生产代理配置
│   └── .env.dev-proxy     # 开发代理配置
├── nginx/                  # Nginx 配置目录
│   ├── README.md          # Nginx 配置说明
│   ├── nginx.conf         # 生产环境配置
│   ├── nginx-dev.conf     # 开发环境配置
│   ├── nginx-local.conf   # 本地开发配置
│   └── conf.d/            # 额外配置目录
├── VSS-frontend/
│   ├── .env.development    # 前端开发环境配置
│   ├── .env.production     # 前端生产环境配置
│   └── .env.proxy          # 前端代理环境配置
└── VSS-backend/
    └── src/main/resources/
        ├── application.properties          # 后端主配置
        ├── application-dev.properties      # 后端开发配置
        ├── application-prod.properties     # 后端生产配置
        └── application-docker.properties   # 后端Docker配置
```

### 🔧 `config/.env.proxy` - Docker 生产代理配置

**用途**: Docker 生产环境的反向代理配置，解决端口冲突问题

**关键配置项**:

```bash
# 端口配置
NGINX_PORT=80              # Nginx 对外端口
DEV_TOOLS_PORT=8080        # 开发工具端口
BACKEND_PORT=3000          # 后端内部端口
FRONTEND_INTERNAL_PORT=80  # 前端内部端口

# 数据库配置
DB_HOST=database          # 数据库主机名
DB_PORT=5432             # 数据库端口
DB_NAME=vss_production_db # 数据库名
DB_USERNAME=prod_user    # 数据库用户名

# API 配置
VITE_API_BASE_URL=/api   # 前端 API 基础路径
API_PREFIX=/api/v1       # 后端 API 前缀
```

**适用场景**:

- ✅ Docker 生产部署
- ✅ 团队协作环境
- ✅ CI/CD 流水线

### 🔧 `config/.env.dev-proxy` - Docker 开发代理配置

**用途**: Docker 开发环境配置，支持热更新

**关键差异**:

```bash
NODE_ENV=development         # 开发环境标识
FRONTEND_DEV_PORT=3000      # 前端开发端口
VITE_HMR_HOST=localhost     # 热更新主机
VITE_HMR_PORT=24678         # 热更新端口
LOG_LEVEL=debug             # 调试日志级别
LOG_CONSOLE_ENABLED=true    # 启用控制台日志
```

**适用场景**:

- ✅ Docker 开发环境
- ✅ 支持热更新的容器化开发
- ✅ 团队开发环境统一

---

## Docker 脚本详解

### 🐳 `docker-manage.bat` - Docker 管理主脚本

**功能**: 统一管理所有 Docker 操作的主入口脚本

**使用方法**:

```cmd
docker-manage.bat [command] [parameters]
```

**核心命令**:

#### 1. 生产代理模式 (推荐部署)

```cmd
docker-manage.bat proxy
```

- **用途**: 生产环境部署
- **特点**: 静态文件服务，高性能
- **端口**: 80 (主服务), 8080 (工具)
- **配置**: 使用 `config/.env.proxy`

#### 2. 开发代理模式 (推荐开发)

```cmd
docker-manage.bat dev-proxy
```

- **用途**: Docker 开发环境
- **特点**: 支持热更新，源码挂载
- **端口**: 80 (主服务), 3000 (前端直连), 24678 (HMR)
- **配置**: 使用 `config/.env.dev-proxy`

#### 3. 标准开发模式

```cmd
docker-manage.bat dev
```

- **用途**: 基础开发环境
- **特点**: 独立端口暴露
- **端口**: 3000 (前端), 3002 (后端)

#### 4. 构建操作

```cmd
docker-manage.bat build [env]
# 示例
docker-manage.bat build dev    # 构建开发镜像
docker-manage.bat build prod   # 构建生产镜像
```

#### 5. 服务管理

```cmd
docker-manage.bat stop         # 停止所有服务
docker-manage.bat restart      # 重启服务
docker-manage.bat status       # 查看服务状态
docker-manage.bat logs [svc]   # 查看日志
```

#### 6. 维护操作

```cmd
docker-manage.bat clean        # 清理资源
docker-manage.bat health       # 健康检查
docker-manage.bat backup       # 数据备份
```

---

## 本地开发指南

### 💻 本地开发环境脚本

#### 1. `setup-local-env.bat` - 本地环境安装脚本

**功能**: 一键安装本地开发环境的所有依赖

**安装内容**:

- Node.js 18+ 环境检查和安装指导
- npm 依赖包安装 (前端)
- Maven/Gradle 依赖安装 (后端)
- Nginx 本地配置生成
- 环境变量配置
- 启动脚本生成

**使用方法**:

```cmd
setup-local-env.bat
```

**生成的文件**:

- `start-all.bat` - 启动所有本地服务
- `start-frontend.bat` - 单独启动前端
- `start-backend.bat` - 单独启动后端
- `nginx-local.conf` - 本地 Nginx 配置
- `dev-guide.bat` - 开发指南

#### 2. `start-all.bat` - 本地服务启动脚本

**功能**: 同时启动前端、后端和 Nginx 代理

**启动顺序**:

1. 后端服务 (端口 3000)
2. 前端开发服务器 (端口 3000)
3. Nginx 本地代理 (端口 8080)

**访问地址**:

- 主应用: `http://localhost:8080` (通过 Nginx 代理)
- 前端直连: `http://localhost:3000` (开发调试)

#### 3. 独立服务脚本

**`start-frontend.bat`**:

```cmd
# 启动前端开发服务器
cd VSS-frontend
npm run dev
```

**`start-backend.bat`**:

```cmd
# 启动后端服务
cd VSS-backend
mvn spring-boot:run
# 或者
./gradlew bootRun
```

---

## 配置文件详解

### 🔧 Docker Compose 配置文件

#### 1. `docker-compose.yml` - 标准配置

```yaml
# 用途: 标准 Docker 部署
# 特点: 每个服务独立暴露端口
services:
  backend:
    ports: ["3002:3002"]
  frontend:
    ports: ["3000:80"]
```

#### 2. `docker-compose.proxy.yml` - 生产代理配置

```yaml
# 用途: 生产环境反向代理
# 特点: 只暴露 nginx 端口，内部服务不对外
services:
  nginx:
    ports: ["80:80", "8080:8080"]
  backend:
    expose: ["3000"]  # 仅内网访问
  frontend:
    volumes: ["frontend-dist:/usr/share/nginx/html"]
```

#### 3. `docker-compose.dev-proxy.yml` - 开发代理配置

```yaml
# 用途: 开发环境热更新代理
# 特点: 源码挂载 + HMR 支持
services:
  frontend-dev:
    ports: ["3000:3000", "24678:24678"]
    volumes:
      - "./VSS-frontend/src:/app/src"  # 源码挂载
    command: ["npm", "run", "dev"]
```

### ⚙️ Nginx 配置文件

#### 1. `nginx/nginx.conf` - 生产代理配置

```nginx
# 特点: 生产环境优化，静态文件服务
upstream vss_backend {
    server backend:3000;
}

location / {
    root /usr/share/nginx/html;  # 静态文件
}

location /api/ {
    proxy_pass http://vss_backend/api/;
}
```

#### 2. `nginx/nginx-dev.conf` - 开发代理配置

```nginx
# 特点: 支持热更新，WebSocket 代理
location / {
    proxy_pass http://vss_frontend_dev;
    # WebSocket 支持 (HMR)
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}

location /@vite/client {
    # Vite HMR WebSocket 专用路由
    proxy_pass http://vss_frontend_dev;
}
```

#### 3. `nginx/nginx-local.conf` - 本地开发配置

```nginx
# 特点: 本地开发环境，端口 8080
upstream vss_backend {
    server 127.0.0.1:3000;  # 本地后端
}

upstream vss_frontend {
    server 127.0.0.1:3000;  # 本地前端开发服务器
}
```

---

## 日常操作手册

### 🚀 环境启动指南

#### 选择开发方式

**1. Docker 开发 (推荐团队)**

```cmd
# 支持热更新的 Docker 开发
docker-manage.bat dev-proxy
# 访问: http://localhost
```

**2. 本地开发 (推荐个人)**

```cmd
# 一键安装和启动
setup-local-env.bat
start-all.bat
# 访问: http://localhost:8080
```

**3. Docker 生产**

```cmd
# 生产环境部署
docker-manage.bat proxy
# 访问: http://localhost
```

### 🔧 日常维护操作

#### 查看服务状态

```cmd
# Docker 服务状态
docker-manage.bat status
docker ps

# 本地服务状态
netstat -an | findstr ":3000"
netstat -an | findstr ":8080"
```

#### 查看日志

```cmd
# Docker 日志
docker-manage.bat logs frontend
docker-manage.bat logs backend
docker-manage.bat logs nginx

# 指定服务日志
docker logs vss-frontend -f
```

#### 重新构建

```cmd
# 重新构建开发镜像
docker-manage.bat build dev

# 重新构建生产镜像  
docker-manage.bat build prod

# 强制重新构建
docker-compose build --no-cache
```

#### 清理和重置

```cmd
# 清理 Docker 资源
docker-manage.bat clean

# 彻底清理 (谨慎使用)
docker system prune -a

# 清理本地缓存
cd VSS-frontend && npm clean-cache
cd VSS-backend && mvn clean
```

### 🔄 热更新测试

#### Docker 开发模式热更新测试

1. 启动开发代理模式:

   ```cmd
   docker-manage.bat dev-proxy
   ```

2. 访问应用: `http://localhost`

3. 修改前端代码:

   ```cmd
   # 编辑 VSS-frontend/src/App.tsx
   # 保存后自动热更新
   ```

4. 查看 HMR 日志:

   ```cmd
   docker logs vss-frontend-dev -f
   ```

#### 本地开发模式热更新测试

1. 启动本地服务:

   ```cmd
   start-all.bat
   ```

2. 访问应用: `http://localhost:8080`

3. 修改代码后自动刷新

---

## 故障排除指南

### ❗ 常见问题

#### 1. 端口冲突

**问题**: `Error: Port 3000 is already in use`

**解决方案**:

```cmd
# 查找占用端口的进程
netstat -ano | findstr :3000

# 结束进程 (使用查到的 PID)
taskkill /PID <PID> /F

# 或者修改配置文件中的端口
```

#### 2. Docker 容器启动失败

**问题**: 容器无法启动或健康检查失败

**解决方案**:

```cmd
# 查看容器日志
docker logs <container-name>

# 检查容器状态
docker ps -a

# 重新启动容器
docker-manage.bat restart
```

#### 3. 热更新不工作

**问题**: 修改代码后页面不自动刷新

**解决方案**:

```cmd
# 检查 HMR WebSocket 连接
# 浏览器 F12 -> Network -> WS 标签页

# 确认端口映射
docker port vss-frontend-dev

# 检查防火墙设置
# Windows: 允许端口 24678 通过防火墙
```

#### 4. Nginx 代理错误

**问题**: `502 Bad Gateway` 或 `Connection refused`

**解决方案**:

```cmd
# 检查上游服务是否运行
docker ps | grep vss-backend
docker ps | grep vss-frontend

# 检查 nginx 配置
docker exec vss-nginx nginx -t

# 重启 nginx 服务
docker restart vss-nginx
```

#### 5. 环境变量未生效

**问题**: 配置修改后不生效

**解决方案**:

```cmd
# 重新启动容器以加载新环境变量
docker-manage.bat stop
docker-manage.bat [mode]

# 检查环境变量是否正确加载
docker exec vss-backend env | grep SERVER_PORT
```

### 🔍 调试技巧

#### 1. 查看容器内部

```cmd
# 进入容器内部
docker exec -it vss-frontend-dev sh
docker exec -it vss-backend bash

# 查看容器内文件
docker exec vss-frontend-dev ls -la /app/src
```

#### 2. 检查网络连接

```cmd
# 测试容器间网络连接
docker exec vss-nginx ping vss-backend
docker exec vss-nginx ping vss-frontend-dev

# 测试端口连通性
docker exec vss-nginx nc -z vss-backend 3000
```

#### 3. 实时日志监控

```cmd
# 同时监控多个容器日志
docker-compose -f docker-compose.dev-proxy.yml logs -f

# 过滤特定日志
docker logs vss-frontend-dev 2>&1 | grep -i error
```

---

## 📞 技术支持

如果遇到本文档未覆盖的问题，请检查以下资源：

1. **项目文档**: `README.md`, `ENVIRONMENT_GUIDE.md`
2. **配置示例**: `UNIFIED-ARCHITECTURE.md`
3. **Docker 文档**: `DOCKER.md`

**联系方式**:

- 项目仓库: VSS GitHub Repository
- 技术文档: 项目 Wiki 页面

---

*最后更新: 2025-07-20*  
*文档版本: v1.0*
