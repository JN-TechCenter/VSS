# VSS 脚本工具集

本目录包含 VSS 项目的所有管理和部署脚本。

## 📁 脚本分类

### 🚀 快速启动脚本
- `quick-start.bat` - 一键快速启动整个 VSS 系统
- `start.bat` - 标准启动脚本

### 🐳 Docker 管理脚本
- `docker-manage.bat` - Docker 容器和服务管理
- `manage.bat` - 综合管理脚本

### ⚙️ 环境配置脚本
- `install-local-env.bat` - 本地环境安装配置
- `setup-local-env.bat` - 本地环境设置

## 🛠️ 使用方法

### 快速开始
```bash
# 进入脚本目录
cd scripts

# 一键启动（推荐新用户）
.\quick-start.bat

# 或者使用标准启动
.\start.bat
```

### Docker 管理
```bash
# Docker 服务管理
.\docker-manage.bat

# 选择操作:
# 1. 启动所有服务
# 2. 停止所有服务  
# 3. 重启服务
# 4. 查看服务状态
# 5. 查看日志
```

### 环境配置
```bash
# 首次安装本地环境
.\install-local-env.bat

# 配置本地开发环境
.\setup-local-env.bat
```

## 📋 脚本功能说明

| 脚本名称 | 主要功能 | 使用场景 |
|---------|---------|---------|
| `quick-start.bat` | 一键启动所有服务 | 新用户快速体验 |
| `start.bat` | 标准启动流程 | 日常开发使用 |
| `docker-manage.bat` | Docker 容器管理 | 服务运维管理 |
| `manage.bat` | 综合管理工具 | 系统维护操作 |
| `install-local-env.bat` | 本地环境安装 | 首次环境配置 |
| `setup-local-env.bat` | 环境参数设置 | 开发环境调优 |

## 🔧 环境要求

- **Windows 10/11** 或更高版本
- **Docker Desktop** 已安装并运行
- **PowerShell 5.1** 或更高版本
- **Git** 版本控制工具

## 📝 使用注意事项

1. **管理员权限**: 某些脚本可能需要管理员权限运行
2. **Docker 依赖**: 确保 Docker Desktop 已启动
3. **端口占用**: 检查所需端口是否被占用
4. **网络连接**: 确保网络连接正常（拉取镜像需要）

## 🚨 故障排除

### 常见问题

**脚本无法执行**
```bash
# 检查执行策略
Get-ExecutionPolicy

# 如需要，设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Docker 启动失败**
```bash
# 检查 Docker 状态
docker version
docker-compose version

# 重启 Docker Desktop
```

**端口冲突**
```bash
# 查看端口占用
netstat -ano | findstr :80
netstat -ano | findstr :3000

# 停止占用端口的进程
taskkill /PID <进程ID> /F
```

## 📞 技术支持

如果在使用脚本过程中遇到问题：

1. 查看脚本输出的错误信息
2. 检查 Docker 容器日志
3. 参考主项目 README.md 文档
4. 提交 Issue 到项目仓库

---

**💡 提示**: 建议将此目录添加到系统 PATH 环境变量中，方便在任意位置调用脚本。
