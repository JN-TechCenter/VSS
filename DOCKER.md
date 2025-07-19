# VSS Docker 部署指南

## 概述

本项目支持通过 Docker 和 Docker Compose 进行容器化部署，包括：
- **前端服务**: React 应用，运行在 nginx 容器中
- **后端服务**: Spring Boot 应用，包含 H2 内存数据库
- **开发环境**: 支持热重载的开发模式

## 前置要求

确保已安装以下软件：
- Docker Desktop (Windows/Mac) 或 Docker Engine (Linux)
- Docker Compose (通常包含在 Docker Desktop 中)

## 快速开始

### 1. 构建镜像

```bash
# Windows
docker-manage.bat build

# Linux/Mac
./docker-manage.sh build
```

### 2. 启动生产环境

```bash
# Windows
docker-manage.bat start

# Linux/Mac
./docker-manage.sh start
```

启动后访问：
- 前端应用: http://localhost:3000
- 后端API: http://localhost:3002
- H2数据库控制台: http://localhost:3002/h2-console

### 3. 启动开发环境

```bash
# Windows
docker-manage.bat dev

# Linux/Mac
./docker-manage.sh dev
```

开发环境特性：

- 支持代码热重载，修改代码后会自动更新
- 详细的调试日志输出
- 开发专用的环境变量配置
- 邮件测试服务（Mailhog）

开发环境访问地址：

- 前端应用: <http://localhost:3001>
- 后端API: <http://localhost:3003>
- 邮件测试: <http://localhost:8025>

## 管理命令

| 命令 | 说明 |
|------|------|
| `build [env]` | 构建镜像 (dev/prod) |
| `start` | 启动生产环境 |
| `dev` | 启动开发环境 |
| `stop` | 停止所有服务 |
| `restart` | 重启服务 |
| `clean` | 清理Docker资源 |
| `logs [service]` | 查看服务日志 |
| `status` | 查看服务状态 |
| `health` | 健康检查 |
| `backup` | 数据备份 |
| `config` | 配置管理 |

## 目录结构

```
VSS/
├── VSS-frontend/
│   ├── Dockerfile          # 生产环境前端镜像
│   ├── Dockerfile.dev      # 开发环境前端镜像
│   ├── .dockerignore       # Docker忽略文件
│   └── nginx.conf          # Nginx配置
├── VSS-backend/
│   ├── Dockerfile          # 后端镜像
│   ├── .dockerignore       # Docker忽略文件
│   └── src/main/resources/
│       └── application-docker.properties  # Docker环境配置
├── docker-compose.yml      # 生产环境配置
├── docker-compose.dev.yml  # 开发环境配置
├── docker-manage.sh        # Linux/Mac管理脚本
└── docker-manage.bat       # Windows管理脚本
```

## 环境配置

### 生产环境 (docker-compose.yml)

- **前端**: nginx + 构建后的静态文件
- **后端**: Spring Boot + H2内存数据库
- **网络**: 独立的Docker网络，服务间通信
- **端口**: 3000(前端), 3002(后端)

### 开发环境 (docker-compose.dev.yml)

- **前端**: Node.js开发服务器，支持热重载
- **后端**: Spring Boot，支持代码挂载
- **卷挂载**: 源代码目录挂载到容器，实现热重载

## 配置管理

### 全局配置系统

VSS 平台采用分层配置管理，完全消除硬编码：

```bash
.env                # 基础配置（所有环境共享）
.env.development    # 开发环境配置
.env.production     # 生产环境配置
.env.docker         # Docker 运行时配置（自动生成）
```

### 配置管理工具

使用内置的配置管理工具来处理环境配置：

```bash
# 显示环境配置
node config-manager.js show dev

# 查看端口配置
node config-manager.js ports prod

# 验证配置文件
node config-manager.js validate dev

# 生成 Docker 环境文件
node config-manager.js docker prod
```

### 个性化配置

所有配置项都可以通过环境变量自定义：

**端口配置**：
- `FRONTEND_PORT` - 前端服务端口
- `BACKEND_PORT` - 后端服务端口  
- `NGINX_PORT` - Nginx 端口
- `MAILHOG_WEB_PORT` - 邮件测试工具端口
- `ADMINER_PORT` - 数据库管理工具端口

**数据库配置**：
- `DB_TYPE` - 数据库类型 (h2/postgres/mysql)
- `DB_HOST` - 数据库主机
- `DB_PORT` - 数据库端口
- `DB_NAME` - 数据库名称

**API 配置**：
- `API_BASE_URL` - API 基础地址
- `API_PREFIX` - API 路径前缀
- `API_TIMEOUT` - API 超时时间
- `API_RATE_LIMIT` - API 请求限制

### 环境差异

| 配置项 | 开发环境 | 生产环境 |
|--------|----------|----------|
| 前端端口 | 3001 | 3000 |
| 后端端口 | 3003 | 3002 |
| 日志级别 | debug | warn |
| 数据库 | H2 内存 | PostgreSQL |
| 热重载 | ✅ | ❌ |
| 邮件测试 | Mailhog | SMTP |

### 后端配置示例

开发环境 (application-dev.properties)：
```properties
# 从环境变量读取配置
server.port=${SERVER_PORT:3003}
server.address=0.0.0.0

# 数据库配置
spring.datasource.url=jdbc:${DB_TYPE}:mem:${DB_NAME}
spring.h2.console.enabled=${H2_CONSOLE_ENABLED:true}

# 日志配置
logging.level.root=${LOG_ROOT_LEVEL:INFO}
logging.level.com.vision=${LOG_LEVEL:DEBUG}

# CORS配置
cors.allowed-origins=${CORS_ORIGIN:*}
```

### 前端配置示例

开发环境变量：
```bash
# API 配置
VITE_API_BASE_URL=${API_BASE_URL}/api/v1
VITE_APP_TITLE=${APP_NAME}
VITE_APP_VERSION=${APP_VERSION}

# 开发工具
VITE_DEV_TOOLS=true
VITE_HOT_RELOAD=true
```

## 故障排除

### 1. 端口冲突

如果遇到端口冲突，修改 docker-compose.yml 中的端口映射：

```yaml
ports:
  - "8080:80"  # 将前端改为8080端口
  - "8081:3002"  # 将后端改为8081端口
```

### 2. 构建失败

清理Docker缓存后重新构建：

```bash
docker system prune -a
docker-manage.bat build
```

### 3. 服务无法访问

检查服务状态：

```bash
docker-manage.bat status
docker-manage.bat logs
```

### 4. 数据库连接问题

确保H2数据库配置正确，检查后端日志：

```bash
docker logs vss-backend
```

## 高级配置

### 使用外部数据库

如需使用PostgreSQL等外部数据库，取消注释docker-compose.yml中的数据库服务：

```yaml
database:
  image: postgres:13
  environment:
    POSTGRES_DB: vss_db
    POSTGRES_USER: vss_user
    POSTGRES_PASSWORD: vss_password
```

### 自定义nginx配置

修改 `VSS-frontend/nginx.conf` 来自定义nginx行为。

### 环境变量配置

在 `.env` 文件中设置环境变量：

```bash
# .env
REACT_APP_API_URL=http://localhost:3002
SPRING_PROFILES_ACTIVE=docker
```

## 生产部署建议

1. **安全性**
   - 更改默认密码
   - 使用HTTPS
   - 限制端口访问

2. **性能优化**
   - 启用gzip压缩
   - 配置缓存策略
   - 使用CDN

3. **监控**
   - 配置日志收集
   - 设置健康检查
   - 监控资源使用

4. **备份**
   - 定期备份数据
   - 测试恢复流程

## 常用Docker命令

```bash
# 查看运行的容器
docker ps

# 查看所有容器
docker ps -a

# 查看镜像
docker images

# 进入容器
docker exec -it vss-backend bash

# 查看容器日志
docker logs vss-frontend

# 停止特定容器
docker stop vss-backend

# 删除容器
docker rm vss-frontend

# 删除镜像
docker rmi vss_frontend:latest
```
