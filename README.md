# VSS Vision Platform

<div align="center">

![VSS Logo](https://via.placeholder.com/200x80/4A90E2/FFFFFF?text=VSS+Vision)

**🚀 现代化视觉检测平台 | 企业级微服务架构**

[![React](https://img.shields.io/badge/React-18.2.0-61DAFB?style=flat-square&logo=react)](https://reactjs.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.8-6DB33F?style=flat-square&logo=spring-boot)](https://spring.io/projects/spring-boot)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-Latest-DC382D?style=flat-square&logo=redis)](https://redis.io/)

[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=flat-square)](https://github.com/JN-TechCenter/VSS)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange?style=flat-square)](https://github.com/JN-TechCenter/VSS/releases)

</div>

---

## 🚀 快速开始

### 📋 环境要求

在开始之前，请确保您的系统已安装以下软件：

- **Git** 2.0+ (版本控制)
- **Docker Desktop** (容器化部署)
- **Node.js** 18+ (前端开发)
- **Java** 17+ (后端开发)
- **Python** 3.8+ (AI服务开发)
- **Go** 1.19+ (网络服务开发，可选)

### ⚡ 30秒快速启动

```bash
# 1. 完整克隆项目（包含所有子模块）
git clone --recursive https://github.com/JN-TechCenter/VSS.git
cd VSS

# 2. 一键启动开发环境
.\scripts\quick-start.bat

# 3. Git 管理 (一步式提交推送)
.\scripts\git-manage.bat push

# 4. 查看项目状态
.\scripts\git-manage.bat status
```

### 🔧 故障排除

如果克隆时遇到子模块问题：

```bash
# 方法1: 重新初始化子模块
git submodule update --init --recursive

# 方法2: 手动修复子模块
cd VSS-backend
git fetch origin
git checkout main
cd ..
git submodule update --init --recursive
```

### 🌐 访问应用

启动成功后，您可以通过以下地址访问各个服务：

| 服务 | 开发地址 | 生产地址 | 健康检查 | 状态 |
|------|----------|----------|----------|------|
| **🎨 前端应用** | http://localhost:3000 | http://localhost | /health | [![Frontend](https://img.shields.io/badge/status-running-green.svg)](http://localhost:3000) |
| **⚙️ 后端API** | http://localhost:8080 | http://localhost/api | /actuator/health | [![Backend](https://img.shields.io/badge/status-running-green.svg)](http://localhost:8080) |
| **🤖 AI推理服务** | http://localhost:8084 | http://localhost/ai | /health | [![AI Service](https://img.shields.io/badge/status-running-green.svg)](http://localhost:8084) |
| **⚡ 网络服务** | http://localhost:8081 | http://localhost/net | /ping | [![Network](https://img.shields.io/badge/status-running-green.svg)](http://localhost:8081) |
| **📊 数据分析** | http://localhost:8082 | http://localhost/data | /health | [![Data Analysis](https://img.shields.io/badge/status-running-green.svg)](http://localhost:8082) |

> **💡 提示**: 点击状态徽章可以直接访问对应的服务！

## 📋 项目概述

VSS (Vision System Studio) 是一个现代化的机器视觉数据分析平台，采用微服务架构设计，为企业级视觉AI应用提供完整的解决方案。

### ✨ 核心特性

- 🎨 **现代化前端**: React + TypeScript + Vite，提供流畅的用户体验
- ⚙️ **企业级后端**: Spring Boot + JPA，稳定可靠的业务逻辑处理
- 🤖 **智能AI服务**: Python + FastAPI + PyTorch，强大的视觉AI推理能力
- ⚡ **高性能网络**: Go + Gin + WebSocket，低延迟实时通信
- 🔷 **跨平台框架**: .NET Core，灵活的业务扩展能力
- 📊 **数据分析**: Python + Pandas，专业的数据处理和分析
- 🐳 **容器化部署**: Docker + Docker Compose，一键部署和扩展
- 🔥 **热更新开发**: 支持前后端热重载，极速开发体验
- 📱 **响应式设计**: 完美适配桌面端和移动端
- 🔒 **安全可靠**: JWT认证、HTTPS加密、数据备份

### 🎯 应用场景

- **工业质检**: 产品缺陷检测、质量控制自动化
- **智能监控**: 视频分析、异常行为识别
- **医疗影像**: 医学图像分析、辅助诊断
- **自动驾驶**: 环境感知、目标识别
- **零售分析**: 客流统计、商品识别

## 🏗️ 系统架构

### 📦 微服务组件

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx 代理     │    │   前端应用       │    │   后端API       │
│   (端口 80)      │◄──►│   (React)       │◄──►│   (Spring Boot) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AI推理服务     │    │   网络服务       │    │   数据分析服务   │
│   (FastAPI)     │    │   (.NET)        │    │   (Python)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │   PostgreSQL    │    │     Redis       │
                    │   (数据库)       │    │    (缓存)       │
                    └─────────────────┘    └─────────────────┘
```

### 🔧 技术栈详情

| 组件 | 技术栈 | 版本 | 端口 | 状态 |
|------|--------|------|------|---------|
| **前端** | React + Vite + TypeScript | 18.2.0 | 3000 | ✅ 完整 |
| **后端** | Spring Boot + Java | 3.2.8 / 17 | 3002 | ✅ 完整 |
| **AI推理** | FastAPI + MindSpore | 0.100+ | 8084 | ✅ 完整 |
| **网络服务** | .NET Framework | - | 8085 | 🚧 基础 |
| **数据分析** | Python + Flask | - | 8086 | 🚧 基础 |
| **代理** | Nginx | Alpine | 80/443 | ✅ 完整 |
| **数据库** | PostgreSQL | 15 | 5432 | ✅ 完整 |
| **缓存** | Redis | Latest | 6379 | ✅ 完整 |

---

## 🛠️ 开发指南

### 📁 项目结构

```
VSS/
├── VSS-frontend/          # React前端应用
│   ├── src/              # 源代码
│   ├── public/           # 静态资源
│   ├── package.json      # 依赖配置
│   └── Dockerfile        # 容器配置
├── VSS-backend/          # Spring Boot后端
│   ├── src/              # Java源代码
│   ├── pom.xml           # Maven配置
│   └── Dockerfile        # 容器配置
├── inference-server/     # AI推理服务
│   ├── app/              # Python应用
│   ├── requirements.txt  # Python依赖
│   └── docker/           # 容器配置
├── net-framework-server/ # .NET网络服务
├── data-analysis-server/ # 数据分析服务
├── nginx/                # Nginx配置
├── database/             # 数据库初始化
├── scripts/              # 脚本工具
├── docs/                 # 项目文档
└── docker-compose.yml    # 容器编排
```

### 🔨 本地开发

#### 前端开发
```bash
cd VSS-frontend
npm install
npm run dev
# 访问: http://localhost:3000
```

#### 后端开发
```bash
cd VSS-backend
./mvnw spring-boot:run
# 访问: http://localhost:3002
```

#### AI推理服务开发
```bash
cd inference-server
pip install -r requirements.txt
python app/main.py
# 访问: http://localhost:8084
```

---

### 🎯 核心技术栈

| 层级 | 技术选型 | 版本要求 | 说明 |
|------|----------|----------|------|
| **前端框架** | React + TypeScript | 18.2.0+ | 现代化UI框架 |
| **构建工具** | Vite | 4.4.0+ | 极速开发体验 |
| **UI组件库** | Ant Design | 5.8.0+ | 企业级组件 |
| **后端框架** | Spring Boot | 3.2.8+ | Java企业级框架 |
| **数据访问** | Spring Data JPA | 3.2.8+ | ORM框架 |
| **AI推理** | FastAPI + PyTorch | 0.100+ | 高性能AI服务 |
| **网络服务** | Go + Gin | 1.21+ | 高并发处理 |
| **数据分析** | Python + Pandas | 3.9+ | 数据处理 |
| **数据库** | PostgreSQL | 15+ | 关系型数据库 |
| **缓存** | Redis | 7+ | 内存数据库 |
| **容器化** | Docker + Compose | 20.10+ | 容器编排 |
| **反向代理** | Nginx | Alpine | 负载均衡 |

## 📁 项目结构

```text
VSS/
├── 📄 README.md                    # 项目主页文档
├── 🐳 docker-compose.yml           # Docker编排配置  
├── 📁 docs/                        # 📚 技术文档中心
│   ├── 01-architecture/            # 🏗️ 架构设计文档
│   ├── 02-api-design/              # 🔌 API设计文档
│   ├── 03-database/                # 💾 数据库设计文档
│   ├── 04-deployment/              # 🚀 部署运维文档
│   ├── 05-development/             # 💻 开发环境文档
│   ├── 06-services/                # 📦 各服务专项文档
│   ├── 07-operations/              # 🔧 运维操作文档
│   ├── 08-guides/                  # 📖 使用指南文档
│   └── 09-archive/                 # 📚 归档历史文档
├── 📁 nginx/                       # 🌐 Web服务器配置
└── 📁 scripts/                     # 🔧 管理脚本集合
    ├── quick-start.bat             # 🚀 一键启动脚本
    ├── git-manage.bat              # 📝 Git管理工具
    └── README.md                   # 脚本使用说明
```

### 🔗 微服务子模块

| 服务 | 技术栈 | 仓库链接 | 本地路径 |
|------|--------|----------|----------|
| **前端服务** | React + TypeScript | [![VSS-frontend](https://img.shields.io/badge/GitHub-VSS--frontend-blue?logo=github)](https://github.com/JN-TechCenter/VSS-frontend) | [`📁 VSS-frontend/`](./VSS-frontend/) |
| **后端服务** | Spring Boot + Java | [![VSS-backend](https://img.shields.io/badge/GitHub-VSS--backend-green?logo=github)](https://github.com/JN-TechCenter/VSS-backend) | [`📁 VSS-backend/`](./VSS-backend/) |
| **AI推理服务** | Python + FastAPI | [![inference-server](https://img.shields.io/badge/GitHub-inference--server-orange?logo=github)](https://github.com/JN-TechCenter/inference_server) | [`📁 inference-server/`](./inference-server/) |
| **网络框架服务** | .NET Framework | [![net-framework-server](https://img.shields.io/badge/GitHub-net--framework--server-purple?logo=github)](https://github.com/JN-TechCenter/net-framework-server) | [`📁 net-framework-server/`](./net-framework-server/) |
| **数据分析服务** | Python + Pandas | [![data-analysis-server](https://img.shields.io/badge/GitHub-data--analysis--server-red?logo=github)](https://github.com/JN-TechCenter/data-analysis-server) | [`📁 data-analysis-server/`](./data-analysis-server/) |

> **💡 提示**: 点击上方的文件夹路径可以直接跳转到对应的子模块目录！

## 🛠️ 脚本工具

项目提供了便捷的脚本工具来简化开发和部署流程：

### 📁 可用脚本

```
scripts/
├── README.md           # 脚本说明文档
├── git-manage.bat      # Git子模块管理
└── quick-start.bat     # 快速启动脚本
```

### 🔧 脚本使用

#### Git 子模块管理
```bash
# Windows
scripts\git-manage.bat

# 功能：
# - 初始化所有子模块
# - 更新子模块到最新版本
# - 重置子模块状态
```

#### 快速启动
```bash
# Windows
scripts\quick-start.bat

# 功能：
# - 检查Docker环境
# - 启动所有服务
# - 显示访问地址
```

### Git 管理工具使用

```bash
# Windows 环境
scripts\git-manage.bat

# 选择操作：
# 1. 查看所有仓库状态
# 2. 拉取最新代码
# 3. 提交所有更改
# 4. 推送到远程仓库
# 5. 创建新分支
# 6. 切换分支
# 7. 合并分支
```

### 快速启动工具

```bash
# Windows 环境
scripts\quick-start.bat

# 自动执行：
# ✅ 检查 Docker 环境
# ✅ 启动数据库服务
# ✅ 启动后端服务
# ✅ 启动前端服务
# ✅ 启动AI推理服务
# ✅ 显示访问地址
```

---

## 📚 文档中心

VSS 提供了完整的文档体系，涵盖从架构设计到运维部署的各个方面：

### 📖 文档分类

```
docs/
├── 01-architecture/     # 🏗️ 系统架构设计
├── 02-api-design/       # 🔌 API接口设计
├── 03-database/         # 🗄️ 数据库设计
├── 04-deployment/       # 🚀 部署运维指南
├── 05-development/      # 💻 开发环境配置
├── 06-services/         # ⚙️ 微服务详解
├── 07-operations/       # 🔧 运维监控指南
├── 08-guides/           # 📋 使用指南
└── 09-archive/          # 📦 历史文档归档
```

### 🎯 快速导航

| 文档类型 | 描述 | 适用人群 |
|----------|------|----------|
| **[架构设计](./docs/01-architecture/)** | 系统整体架构、技术选型 | 架构师、技术负责人 |
| **[API设计](./docs/02-api-design/)** | RESTful API规范、接口文档 | 前后端开发者 |
| **[数据库设计](./docs/03-database/)** | 数据模型、表结构设计 | 后端开发者、DBA |
| **[部署指南](./docs/04-deployment/)** | 生产环境部署、运维配置 | 运维工程师、DevOps |
| **[开发指南](./docs/05-development/)** | 开发环境搭建、编码规范 | 开发者 |
| **[服务详解](./docs/06-services/)** | 各微服务功能、配置说明 | 开发者、运维 |
| **[运维监控](./docs/07-operations/)** | 监控告警、日志分析 | 运维工程师 |
| **[使用指南](./docs/08-guides/)** | 用户手册、最佳实践 | 最终用户、产品经理 |

> **💡 提示**: 点击上方的文档链接可以直接跳转到对应的文档目录！

## 🔍 故障排除

### 常见问题

#### Docker 相关
```bash
# 问题：Docker 服务未启动
# 解决：启动 Docker Desktop 或 Docker 服务

# 问题：端口被占用
# 解决：修改 docker-compose.yml 中的端口配置

# 问题：镜像构建失败
# 解决：清理 Docker 缓存
docker system prune -a
```

#### 子模块相关
```bash
# 问题：子模块更新失败
# 解决：重新初始化子模块
git submodule deinit --all -f
git submodule update --init --recursive

# 问题：子模块指向错误的提交
# 解决：更新子模块到最新版本
git submodule foreach git pull origin main
```

#### 服务启动相关
```bash
# 问题：服务启动超时
# 解决：增加健康检查等待时间

# 问题：数据库连接失败
# 解决：检查数据库服务状态和连接配置

# 问题：AI服务内存不足
# 解决：调整 Docker 内存限制
```

### 获取帮助

如果遇到问题，请按以下顺序寻求帮助：

1. **查看日志**: `docker-compose logs [service-name]`
2. **检查文档**: 查看相关文档目录
3. **搜索Issues**: 在GitHub Issues中搜索类似问题
4. **提交Issue**: 如果问题未解决，请提交新的Issue

详细部署指南请参考：[部署文档](./docs/04-deployment/README.md)

## 📚 文档导航

我们为不同角色的用户提供了完整的文档体系：

### 👥 按角色导航

| 角色 | 推荐文档 | 说明 |
|------|----------|------|
| **🏗️ 架构师** | [架构设计](./docs/01-architecture/) | 系统架构、技术选型、设计理念 |
| **💻 开发者** | [开发指南](./docs/05-development/) | 环境搭建、开发规范、调试技巧 |
| **🚀 运维人员** | [部署运维](./docs/04-deployment/) | 部署方案、监控运维、故障排除 |
| **📋 项目经理** | [项目管理](./docs/08-guides/) | 项目流程、团队协作、进度管理 |

### 📖 按文档类型导航

| 文档类型 | 链接 | 说明 |
|----------|------|------|
| 🏗️ **架构设计** | [docs/01-architecture/](./docs/01-architecture/) | 系统架构与设计理念 |
| 🔌 **API设计** | [docs/02-api-design/](./docs/02-api-design/) | 接口规范与API文档 |
| 💾 **数据库设计** | [docs/03-database/](./docs/03-database/) | 数据模型与数据库设计 |
| 🚀 **部署运维** | [docs/04-deployment/](./docs/04-deployment/) | 部署方案与运维指南 |
| 💻 **开发指南** | [docs/05-development/](./docs/05-development/) | 开发环境与开发规范 |
| 📦 **服务文档** | [docs/06-services/](./docs/06-services/) | 各服务详细说明 |
| 🔧 **运维操作** | [docs/07-operations/](./docs/07-operations/) | 运维操作与监控 |
| 📖 **使用指南** | [docs/08-guides/](./docs/08-guides/) | 快速上手与命令参考 |

> **📚 完整文档**: 访问 [docs/README.md](./docs/README.md) 查看完整的文档导航和使用指南

## 🔧 子模块管理

VSS项目采用Git子模块架构，5个核心服务独立开发和部署：

```bash
# 查看所有仓库状态
.\scripts\git-manage.bat status

# 拉取所有仓库最新代码
.\scripts\git-manage.bat pull

# 推送所有仓库更改
.\scripts\git-manage.bat push

# 同步所有仓库到最新状态
.\scripts\git-manage.bat sync
```

## 🤝 参与贡献

1. **Fork** 本仓库到您的 GitHub
2. **创建** 特性分支 (`git checkout -b feature/AmazingFeature`)  
3. **提交** 您的修改 (`git commit -m 'Add: 添加了令人惊艳的功能'`)
4. **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. **提交** Pull Request

### 🎯 贡献指南

- 遵循现有的代码风格和命名规范
- 为新功能添加相应的测试用例
- 更新相关文档说明
- 确保所有测试通过后再提交PR

## 🚀 部署指南

### 🐳 Docker 容器化部署

#### 生产环境部署
```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f [service-name]

# 停止所有服务
docker-compose down
```

#### 开发环境部署
```bash
# 使用开发配置启动
docker-compose -f docker-compose.yml up -d

# 重新构建特定服务
docker-compose build [service-name]
docker-compose up -d [service-name]
```

### 📊 服务监控

#### 健康检查
```bash
# 检查所有服务健康状态
curl http://localhost/health          # Nginx代理
curl http://localhost:3002/actuator/health  # 后端API
curl http://localhost:8084/health     # AI推理服务
curl http://localhost:8085/health     # 网络服务
curl http://localhost:8086/health     # 数据分析服务
```

#### 日志查看
```bash
# 查看特定服务日志
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f yolo-inference
docker-compose logs -f database
```

### 📊 部署验证

部署完成后，访问以下地址验证服务状态：

- **生产环境**: http://your-domain.com
- **健康检查**: http://your-domain.com/health
- **API文档**: http://your-domain.com/api/docs

详细部署指南请参考：[部署文档](./docs/04-deployment/README.md)

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

## 📞 联系方式

- **项目仓库**: [GitHub - VSS](https://github.com/JN-TechCenter/VSS)
- **问题反馈**: [Issues](https://github.com/JN-TechCenter/VSS/issues)
- **功能建议**: [Discussions](https://github.com/JN-TechCenter/VSS/discussions)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给我们一个 Star！**

Made with ❤️ by [JN-TechCenter](https://github.com/JN-TechCenter)

</div>
