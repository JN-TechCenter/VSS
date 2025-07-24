# VSS 项目管理指南

> **🎯 快速导航**: [新手入门](#-新手入门) | [开发者指南](#-开发者技术指南) | [运维管理](#-运维管理指南)

## 📋 用户指南分类

| 用户类型 | 主要需求 | 推荐阅读 |
|---------|---------|---------|
| **🔰 新手用户** | 快速体验项目 | [新手入门](#-新手入门) |
| **👨‍💻 开发者** | 技术细节、开发环境 | [开发者技术指南](#-开发者技术指南) |
| **🔧 运维人员** | 部署、监控、故障排除 | [运维管理指南](#-运维管理指南) |

---

## 🔰 新手入门

> **目标**: 5分钟内启动并体验VSS项目

### 第一步：获取项目
```bash
# 复制粘贴执行即可
git clone --recursive https://github.com/your-username/VSS.git
cd VSS/scripts
```

### 第二步：一键启动
```bash
# Windows用户直接双击或执行
.\quick-start.bat
```

### 第三步：访问应用
启动完成后，在浏览器中访问：
- **主应用**: http://localhost
- **后端API**: http://localhost:8080
- **AI服务**: http://localhost:8000

### 🎉 完成！
现在您可以开始体验VSS项目的功能了。

### 常见问题
- **启动失败？** 确保已安装Docker Desktop并启动
- **端口冲突？** 关闭占用80、8080、8000端口的程序
- **网络问题？** 检查网络连接，首次启动需下载镜像

---

## 👨‍💻 开发者技术指南

> **目标**: 深入了解技术架构，搭建完整开发环境

### 📋 技术栈概览

| 组件 | 技术栈 | 端口 | 说明 |
|------|--------|------|------|
| **前端** | React + TypeScript + Vite | 3000 | 用户界面 |
| **后端** | Java Spring Boot + Maven | 8080 | 业务逻辑API |
| **AI服务** | Python FastAPI + PyTorch | 8000 | 机器学习推理 |
| **网络服务** | Go + Gin | 9000 | 高性能网络处理 |
| **数据分析** | Python + Pandas | 7000 | 数据处理分析 |
| **数据库** | PostgreSQL | 5432 | 主数据存储 |
| **缓存** | Redis | 6379 | 缓存和会话 |

### 🏗️ 项目架构

```
VSS/ (主仓库)
├── VSS-frontend/          # React前端子模块
├── VSS-backend/           # Java后端子模块  
├── inference-server/      # Python AI服务子模块
├── net-framework-server/  # Go网络服务子模块
├── data-analysis-server/  # Python数据分析子模块
├── docker-compose.yml     # Docker编排配置
├── nginx/                 # 反向代理配置
├── database/              # 数据库初始化脚本
└── scripts/              # 管理脚本工具
```

### 🔧 开发环境搭建

#### 环境要求
```bash
# 必需软件
- Node.js 16+     # 前端开发
- Java 11+        # 后端开发
- Python 3.8+     # AI服务开发
- Go 1.19+        # 网络服务开发
- Maven 3.6+      # Java构建工具
- Docker Desktop  # 容器化部署
- Git 2.30+       # 版本控制
```

#### 克隆完整项目
```bash
# 方法一：递归克隆（推荐）
git clone --recursive https://github.com/your-username/VSS.git

# 方法二：分步克隆
git clone https://github.com/your-username/VSS.git
cd VSS
git submodule update --init --recursive
```

#### 本地开发启动

**前端开发**
```bash
cd VSS-frontend
npm install                    # 安装依赖
npm run dev                   # 启动开发服务器
# 访问: http://localhost:3000
```

**后端开发**
```bash
cd VSS-backend
mvn clean install            # 构建项目
mvn spring-boot:run          # 启动Spring Boot
# 访问: http://localhost:8080
```

**AI服务开发**
```bash
cd inference-server
pip install -r requirements.txt  # 安装Python依赖
python -m uvicorn app.main:app --reload --port 8000
# 访问: http://localhost:8000
```

**Go网络服务开发**
```bash
cd net-framework-server
go mod tidy                   # 安装Go依赖
go run main.go               # 启动Go服务
# 访问: http://localhost:9000
```

### 🔧 Git 子模块管理

使用 `scripts/git-manage.bat` 进行统一的Git操作：

```bash
# 一键拉取所有仓库
.\scripts\git-manage.bat pull

# 一键推送所有仓库  
.\scripts\git-manage.bat push

# 查看所有仓库状态
.\scripts\git-manage.bat status

# 同步到最新状态
.\scripts\git-manage.bat sync

# 仅操作主仓库
.\scripts\git-manage.bat pull-main
.\scripts\git-manage.bat push-main

# 仅操作子模块
.\scripts\git-manage.bat pull-subs
.\scripts\git-manage.bat push-subs
```

### 🔄 开发工作流

#### 功能开发流程
```bash
# 1. 更新到最新代码
.\scripts\git-manage.bat pull

# 2. 创建功能分支
git checkout -b feature/new-feature

# 3. 开发和测试
# ... 编码开发 ...

# 4. 提交更改
git add .
git commit -m "feat: add new feature"

# 5. 推送分支
git push origin feature/new-feature

# 6. 创建Pull Request进行代码审查
```

#### 子模块开发流程
```bash
# 1. 进入子模块目录
cd VSS-frontend

# 2. 创建功能分支
git checkout -b feature/ui-improvement

# 3. 开发功能
# ... 前端开发 ...

# 4. 提交子模块更改
git add .
git commit -m "feat: improve UI components"
git push origin feature/ui-improvement

# 5. 回到主仓库，更新子模块引用
cd ..
git add VSS-frontend
git commit -m "chore: update frontend submodule"
git push origin main
```

### 🧪 测试和调试

#### 单元测试
```bash
# 前端测试
cd VSS-frontend && npm test

# 后端测试  
cd VSS-backend && mvn test

# Python服务测试
cd inference-server && python -m pytest
```

#### 集成测试
```bash
# 启动完整环境进行集成测试
.\scripts\quick-start.bat
# 运行端到端测试脚本
```

### 📊 性能监控

#### 开发环境监控
```bash
# 查看端口占用
netstat -ano | findstr ":3000"
netstat -ano | findstr ":8080"

# 查看进程资源使用
tasklist /fo table

# Docker容器监控
docker stats
```

---

## 🔧 运维管理指南

> **目标**: 生产环境部署、监控和故障排除

### 🐳 Docker 容器管理

#### 基本操作
```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 构建并启动
docker-compose up --build -d
```

#### 单独服务管理
```bash
# 启动特定服务
docker-compose up -d frontend backend

# 重启特定服务
docker-compose restart frontend

# 查看特定服务日志
docker-compose logs -f backend

# 进入容器调试
docker exec -it vss-frontend bash
docker exec -it vss-backend bash
```

#### 高级Docker操作
```bash
# 查看资源使用
docker stats

# 清理无用资源
docker system prune -f

# 强制重建容器
docker-compose down --volumes --remove-orphans
docker-compose build --no-cache
docker-compose up -d
```

### 📊 监控和日志

#### 服务监控
```bash
# 查看所有服务状态
docker-compose ps

# 实时监控资源使用
docker stats

# 查看端口监听状态
netstat -tlnp
```

#### 日志管理
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f frontend
docker-compose logs -f backend

# 查看最近的日志
docker-compose logs --tail=100 backend
```

### 🚨 故障排除

#### Docker相关问题

**容器启动失败**
```bash
# 检查Docker状态
docker version
docker-compose version

# 查看详细错误信息
docker-compose logs

# 清理并重启
docker system prune -f
docker-compose down --volumes --remove-orphans
docker-compose up --build -d
```

**端口冲突**
```bash
# 查看端口占用
netstat -ano | findstr ":80"
netstat -ano | findstr ":3000"
netstat -ano | findstr ":8080"

# 停止占用进程
taskkill /PID <进程ID> /F
```

**内存不足**
```bash
# 查看Docker资源使用
docker stats

# 清理无用镜像和容器
docker system prune -a

# 增加Docker内存限制（Docker Desktop设置）
```

#### Git相关问题

**子模块更新失败**
```bash
# 强制更新子模块
git submodule update --init --recursive --force

# 重置所有子模块
git submodule foreach --recursive git reset --hard
git submodule update --init --recursive
```

**权限问题**
```bash
# 配置Git用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 检查SSH连接
ssh -T git@github.com

# 使用HTTPS替代SSH
git remote set-url origin https://github.com/username/repo.git
```

#### 开发环境问题

**Node.js依赖问题**
```bash
# 清理npm缓存
npm cache clean --force

# 删除依赖重新安装
rm -rf node_modules package-lock.json
npm install

# 使用yarn替代npm
yarn install
```

**Java编译问题**
```bash
# 清理Maven缓存
mvn clean

# 强制更新依赖
mvn clean install -U

# 跳过测试编译
mvn clean install -DskipTests
```

**Python环境问题**
```bash
# 使用虚拟环境
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

# 升级pip
python -m pip install --upgrade pip

# 使用国内镜像源
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

#### 编码和系统问题

**中文显示乱码**
```bash
# 设置控制台编码为UTF-8
chcp 65001

# PowerShell中设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

**PowerShell执行策略**
```bash
# 检查当前策略
Get-ExecutionPolicy

# 设置执行策略（管理员权限）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 🔗 服务访问地址

| 服务 | 开发模式 | Docker模式 | 健康检查 |
|------|---------|------------|----------|
| **前端界面** | http://localhost:3000 | http://localhost | http://localhost/health |
| **后端API** | http://localhost:8080 | http://localhost:8080 | http://localhost:8080/actuator/health |
| **AI推理** | http://localhost:8000 | http://localhost:8000 | http://localhost:8000/health |
| **数据库** | localhost:5432 | localhost:5432 | `pg_isready -h localhost -p 5432` |
| **Redis** | localhost:6379 | localhost:6379 | `redis-cli ping` |

### 🔧 维护操作

#### 定期维护
```bash
# 更新所有代码
.\scripts\git-manage.bat pull

# 重启所有服务
docker-compose restart

# 清理Docker资源
docker system prune -f

# 备份数据库
docker exec vss-database pg_dump -U postgres vss > backup.sql
```

#### 性能优化
```bash
# 查看系统资源使用
tasklist /fo table

# 查看磁盘使用
dir /s

# Docker容器资源限制
# 在docker-compose.yml中添加资源限制
```

---

## 🔗 相关文档

- **项目主页**: [VSS项目README](../../README.md)
- **架构文档**: [../01-architecture/](../01-architecture/)
- **部署指南**: [../04-deployment/](../04-deployment/)
- **开发指南**: [../05-development/](../05-development/)
- **脚本工具**: [../../scripts/](../../scripts/)

---

**📞 技术支持**: 如遇问题，请先查阅本文档相应部分，或提交Issue到项目仓库。

**🎯 文档目标**: 让每个用户都能快速上手，让每个开发者都能深入了解，让每个运维都能稳定部署。