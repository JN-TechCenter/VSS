# VSS 命令速查表

> **日常开发必备** - 最常用命令的快速查询表

## 🚀 启动命令

| 命令 | 说明 | 访问地址 | 热更新 |
|------|------|----------|--------|
| `.\docker-manage.bat proxy` | Docker 生产环境 | <http://localhost> | ❌ |
| `.\docker-manage.bat dev-proxy` | Docker 开发环境 | <http://localhost> | ✅ |
| `setup-local-env.bat` | 本地环境安装 | - | - |
| `start-all.bat` | 本地启动 | <http://localhost:8080> | ✅ |

## 🔧 管理命令

| 操作类型 | 命令 |
|----------|------|
| 查看状态 | `.\docker-manage.bat status` |
| 查看日志 | `.\docker-manage.bat logs [service]` |
| 重启服务 | `.\docker-manage.bat restart` |
| 停止服务 | `.\docker-manage.bat stop` |
| 清理资源 | `.\docker-manage.bat clean` |
| 构建镜像 | `.\docker-manage.bat build` |

## ⚠️ 故障诊断

| 问题类型 | 解决方案 |
|----------|----------|
| 端口冲突 | `netstat -ano \| findstr :3000` |
| 热更新失败 | 检查 F12 -> Network -> WS |
| Nginx 502 | `docker restart vss-nginx` |
| 容器启动失败 | `docker logs [container]` |

## 📋 配置文件

| 文件名 | 用途说明 |
|--------|----------|
| `.env.proxy` | Docker 生产配置 |
| `.env.dev-proxy` | Docker 开发配置 |
| `nginx-dev.conf` | 开发代理配置 |
| `nginx.conf` | 生产代理配置 |

---

*最后更新: 2025-07-20*
