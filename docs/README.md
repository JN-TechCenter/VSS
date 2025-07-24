# 📚 VSS 技术文档中心

<div align="center">

[![项目主页](https://img.shields.io/badge/🏠_项目主页-2196F3?style=for-the-badge&logo=home&logoColor=white)](../README.md)
[![快速开始](https://img.shields.io/badge/🚀_快速开始-4CAF50?style=for-the-badge&logo=rocket&logoColor=white)](./08-guides/quick-start-guide.md)
[![架构设计](https://img.shields.io/badge/🏗️_架构设计-FF9800?style=for-the-badge&logo=architecture&logoColor=white)](./01-architecture/README.md)

</div>

---

## 🎯 文档概述

欢迎来到 **VSS (Vision System Service)** 项目技术文档中心！

**项目简介**
- **项目名称**: VSS 视觉系统服务平台
- **架构模式**: 微服务架构 (5服务设计)
- **技术栈**: React + Java + Python + Go
- **团队规模**: 7人开发团队
- **更新日期**: 2025年1月

---

## 📁 文档导航

### 🎯 按用户角色导航

| 角色 | 推荐文档 | 说明 |
|------|---------|------|
| **🔰 新手用户** | [快速开始](./08-guides/quick-start-guide.md) → [项目管理指南](./08-guides/project-management-guide.md) | 5分钟快速上手 |
| **🏗️ 架构师** | [架构设计](./01-architecture/README.md) → [微服务设计](./01-architecture/microservices-design.md) | 系统架构全貌 |
| **👨‍💻 开发者** | [开发环境](./05-development/README.md) → [API设计](./02-api-design/README.md) | 开发必备文档 |
| **🚀 运维人员** | [部署指南](./04-deployment/README.md) → [运维操作](./07-operations/README.md) | 部署运维指南 |

### 📂 按文档类型导航

#### 🏗️ [01-architecture](./01-architecture/) - 架构设计
> **目标**: 系统架构设计和技术选型

- [架构概览](./01-architecture/architecture-overview.md) - 整体架构设计
- [微服务设计](./01-architecture/microservices-design.md) - 5服务架构详解
- [技术栈选型](./01-architecture/technology-stack.md) - 技术选型说明

#### 🔌 [02-api-design](./02-api-design/) - API设计
> **目标**: 接口设计规范和文档

- [API设计规范](./02-api-design/api-standards.md) - REST API规范
- [接口文档](./02-api-design/api-reference.md) - 完整接口文档
- [服务通信](./02-api-design/service-communication.md) - 服务间通信

#### 💾 [03-database](./03-database/) - 数据库设计
> **目标**: 数据库架构和数据模型

- [数据库设计](./03-database/database-design.md) - 数据库架构
- [数据模型](./03-database/data-models.md) - 表结构设计
- [缓存策略](./03-database/cache-strategy.md) - Redis缓存设计

#### 🚀 [04-deployment](./04-deployment/) - 部署运维
> **目标**: 部署配置和运维指南

- [Docker部署](./04-deployment/docker-setup.md) - 容器化部署
- [环境配置](./04-deployment/environment-config.md) - 环境变量配置
- [CI/CD流程](./04-deployment/cicd-pipeline.md) - 持续集成部署

#### 🔧 [05-development](./05-development/) - 开发环境
> **目标**: 开发环境搭建和规范

- [环境搭建](./05-development/development-setup.md) - 开发环境配置
- [代码规范](./05-development/coding-standards.md) - 编码规范
- [Git工作流](./05-development/git-workflow.md) - 版本控制流程

#### 📦 [06-services](./06-services/) - 服务文档
> **目标**: 各微服务详细文档

- [前端服务](./06-services/react-frontend/) - React前端架构
- [后端服务](./06-services/java-business/) - Java业务服务
- [AI服务](./06-services/python-ai/) - Python AI推理
- [网络服务](./06-services/go-network/) - Go网络代理
- [数据服务](./06-services/python-data/) - Python数据分析

#### 🛠️ [07-operations](./07-operations/) - 运维操作
> **目标**: 系统监控和故障处理

- [监控指南](./07-operations/monitoring.md) - 系统监控
- [故障排除](./07-operations/troubleshooting.md) - 问题诊断
- [性能优化](./07-operations/performance-tuning.md) - 性能调优

#### 📖 [08-guides](./08-guides/) - 使用指南
> **目标**: 用户使用和操作指南

- [快速开始](./08-guides/quick-start-guide.md) - 新手入门
- [项目管理](./08-guides/project-management-guide.md) - 项目管理
- [命令参考](./08-guides/commands-reference.md) - 常用命令

#### 🗂️ [09-archive](./09-archive/) - 历史存档
> **目标**: 历史文档和记录存档

- [优化记录](./09-archive/optimization-records/) - 项目优化历程
- [遗留文档](./09-archive/legacy-documents/) - 历史版本文档
- [会议记录](./09-archive/meeting-notes/) - 重要会议记录

---

## 🎯 快速开始

### 🔰 新手用户 (5分钟上手)
```bash
# 1. 克隆项目
git clone --recursive https://github.com/your-org/VSS.git
cd VSS

# 2. 一键启动
cd scripts
./quick-start.bat

# 3. 访问应用
# 前端: http://localhost:3000
# 后端: http://localhost:8080
```

### 👨‍💻 开发者 (完整环境)
```bash
# 1. 查看开发环境搭建
docs/05-development/development-setup.md

# 2. 了解架构设计
docs/01-architecture/architecture-overview.md

# 3. 查看API文档
docs/02-api-design/api-reference.md
```

### 🚀 运维人员 (部署配置)
```bash
# 1. 查看部署指南
docs/04-deployment/docker-setup.md

# 2. 配置监控
docs/07-operations/monitoring.md

# 3. 故障排除
docs/07-operations/troubleshooting.md
```

---

## 📊 文档状态

### ✅ 已完成文档
- ✅ 架构设计文档
- ✅ 快速开始指南
- ✅ 项目管理指南
- ✅ Docker部署配置

### 🚧 进行中文档
- 🚧 API设计规范
- 🚧 数据库设计文档
- 🚧 开发环境搭建

### 📋 计划创建文档
- 📋 监控运维指南
- 📋 性能优化指南
- 📋 安全配置指南

---

## 🔧 文档维护

### 📝 更新规范
1. **及时更新** - 代码变更时同步更新文档
2. **版本控制** - 重要变更记录版本信息
3. **审核机制** - 文档变更需要团队审核
4. **用户反馈** - 收集用户反馈持续改进

### 🎯 质量标准
- **准确性** - 技术信息准确无误
- **完整性** - 覆盖所有重要功能
- **易读性** - 结构清晰，表达简洁
- **实用性** - 提供可操作的指导

---

## 📞 技术支持

- **项目仓库**: [VSS GitHub](https://github.com/your-org/VSS)
- **问题反馈**: [Issues](https://github.com/your-org/VSS/issues)
- **技术讨论**: [Discussions](https://github.com/your-org/VSS/discussions)

---

**📝 最后更新**: 2025年1月 | **📋 文档版本**: v2.0 | **👥 维护团队**: VSS开发团队
