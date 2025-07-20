# VSS 快速参考指南

> **快速上手指南** - 5分钟掌握 VSS 项目的核心操作

## 🚀 一键启动命令

### Docker 模式

```bash
# 生产环境 (推荐部署)
.\docker-manage.bat proxy

# 开发环境 (支持热更新)
.\docker-manage.bat dev-proxy

# 基础开发
.\docker-manage.bat dev
```

### 本地模式

```bash
# 一键安装环境
setup-local-env.bat

# 启动所有服务
start-all.bat
```

## 📊 端口配置对照表

| 部署模式 | 主访问端口 | 前端直连 | 后端API | 热更新支持 |
|----------|------------|----------|---------|------------|
| Docker 生产 | 80 | - | - | ❌ |
| Docker 开发 | 80 | 3000 | - | ✅ |
| 本地开发 | 8080 | 3000 | 3000 | ✅ |

## 🔧 配置文件速查

| 文件名 | 用途说明 | 适用模式 |
|--------|----------|----------|
| `config/.env.proxy` | Docker 生产配置 | proxy |
| `config/.env.dev-proxy` | Docker 开发配置 | dev-proxy |
| `nginx/nginx.conf` | 生产代理配置 | proxy |
| `nginx/nginx-dev.conf` | 开发代理配置 | dev-proxy |
| `nginx/nginx-local.conf` | 本地代理配置 | 本地开发 |

## 🛠️ 常用维护命令

```bash
# 查看状态
docker ps
.\docker-manage.bat status

# 查看日志
.\docker-manage.bat logs [service]
docker logs [container] -f

# 重启服务
.\docker-manage.bat restart
.\docker-manage.bat stop && .\docker-manage.bat [mode]

# 重新构建
.\docker-manage.bat build [env]
docker-compose build --no-cache

# 清理资源
.\docker-manage.bat clean
```

## 🔍 故障排除速查

### 端口冲突

```bash
# 查找占用进程
netstat -ano | findstr :3000

# 结束进程
taskkill /PID <PID> /F
```

### 热更新不工作

1. 检查浏览器 F12 -> Network -> WS
2. 确认端口 24678 映射
3. 重启开发容器

### Nginx 502 错误

```bash
# 检查上游服务
docker ps | grep vss-

# 测试连接
docker exec vss-nginx ping vss-backend

# 重启 nginx
docker restart vss-nginx
```

## 📁 核心项目结构

```text
VSS/
├── docker-manage.bat          # Docker 管理脚本
├── setup-local-env.bat        # 本地环境安装
├── config/                    # 配置文件目录
│   ├── .env                   # 基础环境变量
│   ├── .env.proxy             # 生产环境配置
│   └── .env.dev-proxy         # 开发环境配置
├── nginx/                     # Nginx 配置目录
│   ├── nginx.conf             # 生产 Nginx 配置
│   ├── nginx-dev.conf         # 开发 Nginx 配置
│   └── nginx-local.conf       # 本地 Nginx 配置
├── docker-compose.yml         # 标准 Docker 配置
├── docker-compose.proxy.yml   # 生产代理配置
├── docker-compose.dev-proxy.yml # 开发代理配置
├── VSS-frontend/
│   ├── Dockerfile             # 生产构建
│   ├── Dockerfile.dev         # 开发构建
│   ├── vite.config.ts         # Vite 配置 (含HMR)
│   └── .env.*                 # 前端环境配置
└── VSS-backend/
    ├── Dockerfile             # 后端构建
    └── src/main/resources/
        └── application*.properties # 后端配置
```

## 🎯 推荐开发工作流

### 团队协作开发

1. `.\docker-manage.bat dev-proxy` (统一 Docker 环境)
2. 修改代码 -> 自动热更新
3. 访问 `http://localhost`

### 个人开发调试

1. `setup-local-env.bat` (一次性安装)
2. `start-all.bat` (日常启动)
3. 访问 `http://localhost:8080`

### 生产环境部署

1. `.\docker-manage.bat proxy`
2. 访问 `http://localhost`

---

*VSS 项目快速参考 v1.0 | 更新时间: 2025-07-20*
