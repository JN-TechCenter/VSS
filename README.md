# VSS (Vision System Studio)

> **现代化的视觉系统开发平台** - 集成前端、后端和容器化部署的完整解决方案

![VSS](https://img.shields.io/badge/VSS-v1.0-blue.svg)
![Docker](https://img.shields.io/badge/Docker-支持-green.svg)
![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green.svg)

## 🚀 快速开始

### 30秒快速启动

```bash
# 一键启动开发环境
.\scripts\quick-start.bat

# Git 管理 (一步式提交推送)
.\scripts\git-manage.bat push

# 查看项目状态
.\scripts\git-manage.bat status
```

### 🌐 访问应用

- **前端应用**: <http://localhost:3000>
- **后端API**: <http://localhost:8080>
- **AI推理服务**: <http://localhost:8084>

## 📋 项目概述

VSS 是一个现代化的机器视觉数据分析平台，采用微服务架构，提供：

- 🎨 **React + TypeScript** 现代化前端界面
- ⚙️ **Spring Boot** 企业级后端服务  
- 🐍 **Python AI** 智能推理服务
- 🐳 **Docker** 一键容器化部署
- 🔥 **热更新** 极速开发体验
- 📱 **响应式** 移动端适配

## 🏗️ 系统架构

### 5服务极简架构

```mermaid
graph TB
    subgraph "🌐 前端层"
        A[React前端应用<br/>TypeScript + Vite]
    end
    
    subgraph "⚡ 微服务层"
        B[☕ Java业务服务<br/>Spring Boot + JPA]
        C[🐍 Python AI服务<br/>FastAPI + PyTorch]
        D[⚡ Go网络服务<br/>Gin + WebSocket]
        E[🔷 .NET框架服务<br/>ASP.NET Core]
        F[📊 数据分析服务<br/>Python + Pandas]
    end
    
    subgraph "💾 数据层"
        G[PostgreSQL<br/>主数据库]
        H[Redis<br/>缓存集群]
    end
    
    A --> B
    A --> C
    A --> D
    A --> E
    A --> F
    
    B --> G
    C --> G
    D --> G
    E --> G
    F --> G
    
    B --> H
    C --> H
    D --> H
    
    style A fill:#e1f5fe
    style B fill:#fce4ec
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#f3e5f5
    style F fill:#fff8e1
    style G fill:#e0f2f1
    style H fill:#ffebee
```

### 🎯 核心技术栈

| 层级 | 技术选型 | 核心优势 |
|------|----------|----------|
| **前端** | React + TypeScript + Vite | 现代化开发体验，类型安全 |
| **业务服务** | Java + Spring Boot | 企业级稳定性，生态成熟 |
| **AI服务** | Python + FastAPI | AI生态丰富，快速迭代 |
| **网络服务** | Go + Gin | 高并发，低延迟 |
| **框架服务** | .NET Core | 跨平台，高性能 |
| **数据分析** | Python + Pandas | 数据处理专业 |
| **数据存储** | PostgreSQL + Redis | 功能全面 + 高性能缓存 |

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
├── 📁 scripts/                     # 🔧 管理脚本集合
│   ├── quick-start.bat             # 🚀 一键启动脚本
│   ├── git-manage.bat              # 📝 Git管理工具
│   └── README.md                   # 脚本使用说明
└── 📁 config/                      # ⚙️ 配置文件目录
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

## 🚀 开发指南

### 环境要求

- **Node.js** 18+ (前端开发)
- **Java** 17+ (后端开发)
- **Python** 3.8+ (AI服务开发)
- **Go** 1.19+ (网络服务开发)
- **Git** 2.0+ (版本控制)
- **Docker** (可选，容器化部署)

### 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/JN-TechCenter/VSS.git
cd VSS

# 2. 一键启动开发环境
.\scripts\quick-start.bat

# 3. 访问应用
# 前端: http://localhost:3000
# 后端: http://localhost:8080
```

### 🔧 脚本工具

VSS 提供了强大的脚本工具集，简化开发和运维操作：

| 脚本 | 功能 | 使用场景 |
|------|------|----------|
| **quick-start.bat** | 一键启动开发环境 | 项目初始化、日常开发 |
| **git-manage.bat** | Git统一管理工具 | 代码提交、推送、状态检查 |

#### Git 管理工具使用

```bash
# 一步式提交推送 (自动模式)
.\scripts\git-manage.bat push

# 交互式提交推送 (手动输入提交信息)
.\scripts\git-manage.bat push-interactive

# 拉取所有仓库更新
.\scripts\git-manage.bat pull

# 检查所有仓库状态
.\scripts\git-manage.bat status

# 同步所有仓库到最新状态
.\scripts\git-manage.bat sync
```

### 🌐 服务访问地址

| 服务 | 开发模式 | 健康检查 | 说明 |
|------|----------|----------|------|
| **前端** | http://localhost:3000 | /health | React开发服务器 |
| **后端** | http://localhost:8080 | /actuator/health | Spring Boot应用 |
| **AI服务** | http://localhost:8084 | /health | Python FastAPI |
| **网络服务** | http://localhost:8081 | /ping | Go Gin服务 |
| **数据分析** | http://localhost:8082 | /health | Python数据服务 |

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

## 🚀 生产部署

```bash
# Docker 容器化部署
docker-compose up -d

# 访问应用
http://localhost
```

详细部署指南请参考：[部署文档](./docs/04-deployment/README.md)

## 📞 联系方式

- **📂 项目仓库**: [VSS GitHub Repository](https://github.com/JN-TechCenter/VSS)
- **🐛 问题反馈**: [GitHub Issues](https://github.com/JN-TechCenter/VSS/issues)  
- **📖 技术文档**: [项目文档中心](./docs/README.md)
- **🔧 脚本工具**: [脚本使用指南](./scripts/README.md)

## 📈 项目状态

- ✅ **文档体系**: 完整的9类文档分类，覆盖架构到运维
- ✅ **脚本工具**: 一键启动、Git统一管理、自动化部署
- ✅ **微服务架构**: 5服务独立开发，容器化部署
- 🔄 **持续集成**: GitHub Actions自动化CI/CD
- 📊 **监控体系**: 健康检查、日志聚合、性能监控

---

*📅 最后更新: 2024-12-19 | 🏷️ 版本: v1.0 | ⭐ 如果这个项目对您有帮助，请点个 Star！*
## 🤝 参与贡献

1. **Fork** 本仓库到您的 GitHub
2. **创建** 特性分支 (`git checkout -b feature/AmazingFeature`)  
3. **提交** 您的修改 (`git commit -m 'Add: 添加了令人惊艳的功能'`)
4. **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. **提交** Pull Request

## 🚀 生产部署

```bash
# Docker 生产部署
.\docker-manage.bat proxy

# 访问应用
http://localhost
```

## 📞 联系方式

- **📂 项目仓库**: [VSS GitHub Repository](https://github.com/JN-TechCenter/VSS)
- **🐛 问题反馈**: [GitHub Issues](https://github.com/JN-TechCenter/VSS/issues)  
- **📖 技术文档**: [项目 Wiki](https://github.com/JN-TechCenter/VSS/wiki)

---

*📅 最后更新: 2025-07-21 | 🏷️ 版本: v1.0 | ⭐ 如果这个项目对您有帮助，请点个 Star！*
