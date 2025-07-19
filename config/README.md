# Config 配置文件目录

> **环境配置管理** - 统一管理所有环境变量和配置文件

## 📁 文件结构

```text
config/
├── README.md          # 本说明文档
├── .env              # 基础环境变量
├── .env.proxy        # Docker 生产代理配置
└── .env.dev-proxy    # Docker 开发代理配置
```

## 🔧 配置文件说明

### 📄 `.env` - 基础环境变量

**用途**: 通用的环境变量配置

```bash
# 项目基础配置
PROJECT_NAME=VSS
PROJECT_VERSION=1.0.0

# 默认端口配置
DEFAULT_FRONTEND_PORT=3000
DEFAULT_BACKEND_PORT=3000
DEFAULT_NGINX_PORT=80
```

### 📄 `.env.proxy` - Docker 生产代理配置

**用途**: Docker 生产环境的环境变量

```bash
# 端口配置
NGINX_PORT=80              # Nginx 对外端口
DEV_TOOLS_PORT=8080        # 开发工具端口
BACKEND_PORT=3000          # 后端内部端口
FRONTEND_INTERNAL_PORT=80  # 前端内部端口

# 网络配置
DOCKER_NETWORK=vss-network

# 数据库配置
DB_HOST=database
DB_PORT=5432
DB_NAME=vss_production_db
DB_USERNAME=prod_user
# DB_PASSWORD=your_secure_password  # 请在部署时设置

# API 配置
VITE_API_BASE_URL=/api
API_PREFIX=/api/v1

# 生产环境配置
NODE_ENV=production
LOG_LEVEL=info
```

**适用场景**: `.\docker-manage.bat proxy`

### 📄 `.env.dev-proxy` - Docker 开发代理配置

**用途**: Docker 开发环境的环境变量

```bash
# 端口配置
NGINX_PORT=80
DEV_TOOLS_PORT=8080
BACKEND_PORT=3000
FRONTEND_DEV_PORT=3000

# 热更新配置
VITE_HMR_HOST=localhost
VITE_HMR_PORT=24678

# 开发环境配置
NODE_ENV=development
LOG_LEVEL=debug
LOG_CONSOLE_ENABLED=true

# 开发数据库配置
DB_HOST=database-dev
DB_NAME=vss_development_db
DB_USERNAME=dev_user

# API 配置
VITE_API_BASE_URL=/api
API_PREFIX=/api/v1
```

**适用场景**: `.\docker-manage.bat dev-proxy`

## 🚀 使用说明

### 在 Docker Compose 中使用

```bash
# 生产环境
docker-compose -f docker-compose.proxy.yml --env-file config/.env.proxy up -d

# 开发环境
docker-compose -f docker-compose.dev-proxy.yml --env-file config/.env.dev-proxy up -d
```

### 在脚本中引用

```bash
# docker-manage.bat 自动使用对应的配置文件
.\docker-manage.bat proxy      # 使用 config/.env.proxy
.\docker-manage.bat dev-proxy  # 使用 config/.env.dev-proxy
```

## 🔧 配置自定义

### 添加新的环境变量

1. 在对应的 `.env` 文件中添加变量
2. 在 Docker Compose 文件中引用
3. 在应用代码中使用

**示例**:

```bash
# 在 .env.proxy 中添加
CUSTOM_API_TIMEOUT=30000

# 在 docker-compose.proxy.yml 中引用
environment:
  - API_TIMEOUT=${CUSTOM_API_TIMEOUT}

# 在应用中使用
const timeout = process.env.API_TIMEOUT || 5000;
```

### 环境特定配置

```bash
# 开发环境特有配置
DEBUG_MODE=true
MOCK_API_ENABLED=true

# 生产环境特有配置
ENABLE_COMPRESSION=true
CACHE_TTL=3600
```

## 🔒 安全注意事项

### 敏感信息处理

```bash
# ❌ 不要在配置文件中明文存储密码
DB_PASSWORD=admin123

# ✅ 使用占位符，在部署时替换
DB_PASSWORD=${DB_PASSWORD_SECRET}

# ✅ 或使用 Docker secrets
DB_PASSWORD_FILE=/run/secrets/db_password
```

### 文件权限

```bash
# 限制配置文件访问权限
chmod 600 config/.env*

# 添加到 .gitignore (如果包含敏感信息)
echo "config/.env.local" >> .gitignore
```

## 🔄 配置验证

### 检查配置语法

```bash
# 验证环境变量格式
docker-compose -f docker-compose.proxy.yml --env-file config/.env.proxy config

# 查看最终配置
docker-compose -f docker-compose.proxy.yml --env-file config/.env.proxy config > final-config.yml
```

### 配置测试

```bash
# 测试配置是否正确
docker-compose -f docker-compose.proxy.yml --env-file config/.env.proxy up --dry-run
```

## 📋 配置模板

### 创建新环境配置

```bash
# 复制现有配置
cp config/.env.proxy config/.env.staging

# 修改特定环境的值
sed -i 's/production/staging/g' config/.env.staging
```

### 配置文件命名规范

```text
.env                    # 基础配置
.env.local             # 本地开发配置
.env.development       # 开发环境配置
.env.staging           # 测试环境配置
.env.production        # 生产环境配置
.env.proxy             # 代理模式配置
.env.dev-proxy         # 开发代理配置
```

## 🐛 故障排除

### 配置不生效

```bash
# 检查文件路径
ls -la config/.env*

# 检查文件内容
cat config/.env.proxy

# 验证 Docker Compose 是否读取到配置
docker-compose --env-file config/.env.proxy config
```

### 环境变量冲突

```bash
# 查看当前环境变量
docker-compose -f docker-compose.proxy.yml --env-file config/.env.proxy exec nginx env

# 清理环境变量缓存
docker-compose down
docker system prune -f
```

---

*最后更新: 2025-07-20*
