# VSS 端口配置最佳实践 - 反向代理方案

## 🎯 核心原则

**避免硬编码端口，使用相对路径和环境变量**

## 📝 配置原则

### ✅ 推荐做法

1. **前端配置**：
   - 使用相对路径：`/api`、`/ws` 
   - 避免硬编码端口：不使用 `http://localhost:3002`
   - 通过环境变量配置：`VITE_API_BASE_URL=/api`

2. **后端配置**：
   - CORS 允许源不包含端口：`http://localhost`
   - 使用容器名通信：`http://frontend`
   - 端口通过环境变量：`${SERVER_PORT:3002}`

3. **nginx 配置**：
   - 统一入口：只暴露端口 80 和 8080
   - 内部路由：通过路径区分服务
   - 上游服务：使用容器名和内部端口

### ❌ 避免做法

1. **不要硬编码端口**：
   ```javascript
   // ❌ 错误
   const API_URL = 'http://localhost:3002/api';
   
   // ✅ 正确
   const API_URL = '/api';
   ```

2. **不要在 CORS 中指定端口**：
   ```properties
   # ❌ 错误
   cors.allowed-origins=http://localhost:3000
   
   # ✅ 正确
   cors.allowed-origins=http://localhost
   ```

3. **不要在 Docker Compose 中暴露不必要的端口**：
   ```yaml
   # ❌ 错误
   ports:
     - "3002:3002"
   
   # ✅ 正确
   expose:
     - "3002"
   ```

## 🔧 配置文件更新

### 1. 前端配置 (`vite.config.ts`)

```typescript
export default defineConfig({
  plugins: [react()],
  server: {
    // 使用环境变量端口，避免硬编码
    port: parseInt(process.env.VITE_PORT || '3000'),
    host: true,
    // 代理配置 - 开发环境使用
    proxy: {
      '/api': {
        target: process.env.VITE_API_BASE_URL || 'http://localhost:3002',
        changeOrigin: true,
        secure: false
      }
    }
  },
  // 环境变量配置
  define: {
    __API_BASE_URL__: JSON.stringify(process.env.VITE_API_BASE_URL || '/api')
  }
});
```

### 2. 前端 API 客户端 (`client.ts`)

```typescript
export class VisionPlatformAPI implements APIClient {
  // 使用相对路径，避免硬编码端口
  private baseURL: string = import.meta.env.VITE_API_BASE_URL || '/api';
  private scriptBaseURL: string = import.meta.env.VITE_SCRIPT_SERVICE_URL || '/api/scripts';
}
```

### 3. 后端配置 (`application-docker.properties`)

```properties
# 服务器配置 - 使用环境变量
server.port=${SERVER_PORT:3002}
server.address=0.0.0.0

# CORS 配置 - 不指定端口
cors.allowed-origins=${CORS_ORIGIN:http://localhost,http://frontend,https://localhost}
```

### 4. 环境变量 (`.env.proxy`)

```bash
# 端口配置 - 只指定对外端口
NGINX_PORT=80
DEV_TOOLS_PORT=8080

# 内部端口 - 不对外暴露
BACKEND_PORT=3002
FRONTEND_INTERNAL_PORT=3000

# API 配置 - 使用相对路径
VITE_API_BASE_URL=/api
VITE_WS_URL=/ws
```

### 5. Docker Compose (`docker-compose.proxy.yml`)

```yaml
services:
  nginx:
    ports:
      - "${NGINX_PORT:-80}:80"     # 唯一对外端口
      - "${DEV_TOOLS_PORT:-8080}:8080"
  
  backend:
    expose:
      - "${BACKEND_PORT:-3002}"    # 只内网暴露
    # 不使用 ports 配置
  
  frontend:
    expose:
      - "${FRONTEND_INTERNAL_PORT:-3000}"  # 只内网暴露
    # 不使用 ports 配置
    build:
      args:
        - VITE_API_BASE_URL=/api   # 相对路径
```

## 🌐 路由配置

### nginx 路由规则

```nginx
# 前端应用 - 根路径
location / {
    proxy_pass http://vss_frontend;
}

# API 接口 - /api 路径
location /api/ {
    proxy_pass http://vss_backend/api/;
}

# WebSocket - /ws 路径
location /ws {
    proxy_pass http://vss_backend/ws;
}
```

### 上游服务定义

```nginx
upstream vss_backend {
    server backend:3002;    # 使用容器名和内部端口
}

upstream vss_frontend {
    server frontend:3000;   # 使用容器名和内部端口
}
```

## 🔍 验证配置

### 检查前端配置
```bash
# 检查前端是否使用相对路径
grep -r "localhost:300" VSS-frontend/src/  # 应该没有结果

# 检查环境变量使用
grep -r "VITE_API_BASE_URL" VSS-frontend/src/
```

### 检查后端配置
```bash
# 检查 CORS 配置
grep "cors.allowed-origins" VSS-backend/src/main/resources/

# 检查端口配置
grep "server.port" VSS-backend/src/main/resources/
```

### 检查 Docker 配置
```bash
# 检查端口暴露
grep -A 5 -B 5 "ports:" docker-compose.proxy.yml

# 检查环境变量
grep "VITE_API_BASE_URL" docker-compose.proxy.yml
```

## 🎯 优势总结

### 1. **灵活性**
- 可以在任何环境部署，无需修改代码
- 支持不同的域名和端口配置

### 2. **安全性**
- 内部服务不直接暴露
- 统一的安全策略和访问控制

### 3. **可维护性**
- 配置集中管理
- 减少硬编码，降低出错概率

### 4. **可扩展性**
- 支持负载均衡
- 支持微服务架构

## 🚀 部署优势

使用这种配置方式，您的应用：

1. **完全解决端口冲突问题**
2. **支持任意环境部署**
3. **配置更加灵活和安全**
4. **维护成本更低**

---

**关键要点**：通过避免硬编码端口，使用相对路径和环境变量，您的 VSS Vision Platform 现在可以在任何环境中无缝部署，完全不用担心端口冲突问题！
