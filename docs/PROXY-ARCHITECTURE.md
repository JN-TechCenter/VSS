# VSS 反向代理架构说明

## 🏗️ 架构概览

```
外部访问 → Nginx (80端口) → 内部服务
```

## 📊 端口分配详情

### 对外暴露端口
| 端口 | 服务 | 用途 | 访问地址 |
|------|------|------|----------|
| 80   | Nginx | 主要服务入口 | http://localhost |
| 8080 | Nginx | 开发工具入口 | http://localhost:8080 |

### 内部容器端口（不对外暴露）
| 容器 | 内部端口 | 服务类型 | Nginx路由 |
|------|----------|----------|-----------|
| vss-frontend | 3000 | React应用 | `/` → `frontend:3000` |
| vss-backend | 3002 | Spring Boot | `/api/` → `backend:3002/api/` |
| vss-database | 5432 | PostgreSQL | 内部访问 |
| vss-redis | 6379 | Redis缓存 | 内部访问 |

## 🔄 请求路由流程

### 前端页面访问
```
用户浏览器 → http://localhost/ 
           → Nginx:80 
           → frontend:3000 
           → React应用
```

### API请求
```
前端应用 → http://localhost/api/users/register 
         → Nginx:80 
         → backend:3002/api/users/register 
         → Spring Boot API
```

### WebSocket连接
```
前端应用 → http://localhost/ws/ 
         → Nginx:80 
         → backend:3002/ws/ 
         → Spring Boot WebSocket
```

## 🛡️ 安全优势

1. **端口隔离**: 只暴露必要的端口（80, 8080）
2. **统一入口**: 所有请求通过Nginx统一管理
3. **内网通信**: 容器间使用内部网络通信
4. **负载均衡**: Nginx提供负载均衡能力
5. **SSL支持**: 可在Nginx层统一配置HTTPS

## 🚀 启动方式

```bash
# 推荐方式 - 代理模式
docker-manage.bat proxy

# 访问应用
http://localhost          # 主应用
http://localhost:8080     # 开发工具
```

## 🔍 故障排除

### 检查端口占用
```bash
# 检查对外端口
netstat -an | findstr ":80"
netstat -an | findstr ":8080"

# 内部端口不应该对外可见
netstat -an | findstr ":3000"  # 应该为空
netstat -an | findstr ":3002"  # 应该为空
```

### 检查容器状态
```bash
docker-manage.bat status
docker-compose -f docker-compose.proxy.yml ps
```

### 查看Nginx日志
```bash
docker-manage.bat logs nginx
```

## 💡 开发说明

- 前端开发：代码修改会通过Vite热重载自动更新
- 后端开发：API修改需要重启后端容器
- 配置修改：Nginx配置修改需要重启Nginx容器
- 数据库：使用Docker volumes持久化数据

## 🔧 自定义配置

### 修改端口
如需修改端口，编辑以下文件：
- `docker-compose.proxy.yml` - Docker服务配置
- `nginx.conf` - Nginx路由配置
- `.env.proxy` - 环境变量配置
