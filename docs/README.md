# 📚 VSS 技术文档导航中心

<div align="center">

[![项目主页](https://img.shields.io/badge/🏠_项目主页-2196F3?style=for-the-badge&logo=home&logoColor=white)](../README.md)
[![文档结构说明](https://img.shields.io/badge/📂_文档结构说明-4CAF50?style=for-the-badge&logo=folder&logoColor=white)](./DOCS-STRUCTURE.md)

</div>

---

## 🎯 文档概述

欢迎来到VSS (Vision System Service) 项目技术文档中心！本页面为您提供完整的文档导航，帮助您快速找到所需的技术信息。

**项目信息**
- 项目名称: VSS 视觉系统服务平台
- 架构模式: 微服务架构 (5服务极简版)
- 团队规模: 7人开发团队
- 技术栈: Python + Go + Java + React
- 更新日期: 2025年7月21日

> **📂 新版本说明**: 文档已采用结构化目录管理，详见 [文档目录结构说明](./DOCS-STRUCTURE.md)

---

## 📁 结构化文档目录

### 🏗️ [01-architecture](./01-architecture/) - 架构设计文档
**目标受众**: 架构师、技术负责人、全体开发人员  
**核心文档**:
- [总体架构设计](./01-architecture/architecture-overview.md) - 5服务极简架构
- [微服务优化总结](./01-architecture/microservices-design-summary.md) - 批判性优化历程

### 🌐 [02-api-design](./02-api-design/) - API设计文档  
**目标受众**: 全体开发人员、前后端对接人员  
**规划文档**: API设计规范、REST接口参考、WebSocket协议、服务间通信

### 💾 [03-database](./03-database/) - 数据库设计文档
**目标受众**: 后端开发团队、DBA  
**规划文档**: PostgreSQL架构设计、Redis缓存策略、数据迁移方案

### 🚀 [04-deployment](./04-deployment/) - 部署运维文档
**目标受众**: DevOps工程师、运维团队  
**核心文档**:
- [Docker部署配置](./04-deployment/docker-setup.md) - 容器化部署指南

### 🔧 [05-development](./05-development/) - 开发环境文档
**目标受众**: 全体开发人员  
**核心文档**:
- [开发环境搭建](./05-development/development-setup.md) - 完整开发环境配置

### 📦 [06-services](./06-services/) - 各服务专项文档
**目标受众**: 对应技术栈开发人员  
**服务模块**:
- [Python AI服务](./06-services/python-ai/) - AI推理引擎、模型管理
- [Go网络服务](./06-services/go-network/) - 网络代理、WebSocket通信  
- [Java业务服务](./06-services/java-business/) - 用户、设备、配置服务
- [React前端](./06-services/react-frontend/) - 前端架构、组件设计

### 🛠️ [07-operations](./07-operations/) - 运维操作文档
**目标受众**: 运维人员、技术支持  
**规划文档**: 监控指南、故障排除、备份恢复、安全管理

### 📖 [08-guides](./08-guides/) - 使用指南文档  
**目标受众**: 最终用户、产品人员  
**核心文档**:
- [快速开始指南](./08-guides/quick-start-guide.md) - 系统快速上手
- [命令参考手册](./08-guides/commands-reference.md) - 常用命令速查

### 🗂️ [09-archive](./09-archive/) - 历史文档存档
**目标受众**: 需要历史信息的人员  
**存档内容**:
- [优化记录](./09-archive/optimization-records/) - 项目优化历程
- [遗留文档](./09-archive/legacy-documents/) - 历史版本文档

---

## 🎯 快速导航指南

### 👨‍💻 按角色导航

#### 🔧 技术负责人/架构师
**推荐阅读顺序**:
1. [总体架构设计](./01-architecture/architecture-overview.md) - 了解整体架构
2. [微服务优化总结](./01-architecture/microservices-design-summary.md) - 理解设计决策
3. [AI推理服务](./06-services/python-ai/ai-inference-service.md) - 核心技术组件

#### 🐍 Python AI团队
**推荐阅读顺序**:
1. [AI推理服务](./06-services/python-ai/ai-inference-service.md) - 核心工作内容
2. [总体架构设计](./01-architecture/architecture-overview.md) - 理解系统集成
3. [API设计规范](./02-api-design/) - 服务对接规范

#### ⚡ Go网络服务团队
**推荐阅读顺序**:
1. [Go网络服务](./06-services/go-network/) - 服务架构设计
2. [总体架构设计](./01-architecture/architecture-overview.md) - 服务定位
3. [部署运维文档](./04-deployment/) - 服务部署

#### ☕ Java业务服务团队
**推荐阅读顺序**:
1. [Java业务服务](./06-services/java-business/) - 业务服务设计
2. [数据库设计](./03-database/) - 数据模型
3. [总体架构设计](./01-architecture/architecture-overview.md) - 业务集成

#### ⚛️ React前端团队
**推荐阅读顺序**:
1. [React前端服务](./06-services/react-frontend/) - 前端架构
2. [API设计规范](./02-api-design/) - 前后端对接
3. [开发环境搭建](./05-development/development-setup.md) - 开发配置

#### 🚀 DevOps/运维团队
**推荐阅读顺序**:
1. [部署运维文档](./04-deployment/) - 核心职责
2. [运维操作文档](./07-operations/) - 日常运维
3. [总体架构设计](./01-architecture/architecture-overview.md) - 系统理解

### 📋 按任务导航

#### 🎯 系统了解
**新人入职必读**:
- [总体架构设计](./01-architecture/architecture-overview.md)
- [微服务优化总结](./01-architecture/microservices-design-summary.md)
- [快速开始指南](./08-guides/quick-start-guide.md)

#### 🔧 功能开发
**开发阶段参考**:
- [API设计规范](./02-api-design/)
- [数据库设计](./03-database/)
- [各服务专项文档](./06-services/)

#### 🚀 系统部署
**部署阶段指南**:
- [Docker部署配置](./04-deployment/docker-setup.md)
- [部署运维文档](./04-deployment/)
- [运维操作文档](./07-operations/)

#### 🐛 问题排查
**故障处理参考**:
- [运维操作文档](./07-operations/) - 故障排除
- [AI推理服务](./06-services/python-ai/ai-inference-service.md) - AI相关问题
- [命令参考手册](./08-guides/commands-reference.md) - 操作命令

---

## 📊 文档状态追踪

### ✅ 已完成文档

| 文档名称 | 完成状态 | 最后更新 | 负责人 |
|----------|----------|----------|--------|
| 总体架构设计 | ✅ 完成 | 2025-07-21 | 架构师 |
| AI推理服务 | ✅ 完成 | 2025-07-21 | AI团队 |
| 微服务优化总结 | ✅ 完成 | 2025-07-21 | 技术负责人 |
| 文档结构说明 | ✅ 完成 | 2025-07-21 | 技术负责人 |

### 🚧 计划创建文档

| 文档名称 | 优先级 | 预计完成时间 | 负责团队 |
|----------|--------|--------------|----------|
| Docker部署配置 | 🔴 高 | 2025-07-25 | DevOps团队 |
| API设计规范 | 🔴 高 | 2025-07-28 | 后端团队 |
| 开发环境搭建 | 🟡 中 | 2025-08-01 | 全体团队 |
| 数据库设计 | 🟡 中 | 2025-08-05 | 后端团队 |
| 快速开始指南 | 🟡 中 | 2025-08-08 | 产品团队 |
| 各服务专项文档 | 🟢 低 | 2025-08-15 | 各技术团队 |

---

## 🔧 文档维护规范

### 📝 文档更新流程

1. **文档修改** - 在对应目录中进行文档修改
2. **版本标记** - 更新文档头部的版本信息
3. **目录更新** - 确保目录README文件与内容同步
4. **导航更新** - 在本导航页面更新相关链接
5. **团队通知** - 通知相关团队成员文档变更

### 📋 目录结构规范

- **01-09编号** - 使用两位数字前缀保证排序
- **分类明确** - 每个目录有明确的文档类型
- **README必备** - 每个目录必须有README.md说明
- **版本控制** - 所有文档纳入Git版本控制
- **文件命名** - 使用kebab-case命名规范

### 🎯 质量标准

- **完整性** - 覆盖所有重要技术点
- **准确性** - 技术信息准确无误
- **结构化** - 层次清晰，便于导航
- **实用性** - 提供可操作的指导
- **时效性** - 与代码保持同步更新

---

## 📞 联系与反馈

### 🤝 文档贡献

如果您发现文档问题或有改进建议，请通过以下方式贡献：

1. **直接修改** - Fork仓库并提交PR
2. **问题反馈** - 在GitHub Issues中报告问题
3. **改进建议** - 在团队会议中提出建议
4. **新文档请求** - 向技术负责人申请创建新文档

### 📧 技术支持

- **架构问题** - 联系架构师团队
- **AI相关** - 联系Python AI团队
- **部署问题** - 联系DevOps团队
- **业务逻辑** - 联系Java业务团队
- **前端界面** - 联系React前端团队
- **网络通信** - 联系Go网络团队

---

## 🎉 结语

结构化文档管理系统将帮助VSS项目团队：

- **快速定位** - 根据编号目录快速找到相关文档
- **分工明确** - 按技术栈和职责清晰分类
- **便于维护** - 结构化管理降低维护成本
- **高效协作** - 基于统一的目录规范进行团队协作
- **持续改进** - 通过版本控制跟踪文档演进

**让我们一起构建高质量的结构化技术文档体系，为VSS项目的成功奠定坚实基础！** 🚀

---

<div align="center">

## 🧭 快速导航

[![🏠 返回项目主页](https://img.shields.io/badge/🏠_返回项目主页-2196F3?style=for-the-badge&logo=home&logoColor=white)](../README.md)
[![📂 文档结构](https://img.shields.io/badge/📂_文档结构说明-4CAF50?style=for-the-badge&logo=folder&logoColor=white)](./DOCS-STRUCTURE.md)

---

### 🔥 热门文档

[![🏗️ 总体架构](https://img.shields.io/badge/🏗️_总体架构-blue?style=flat-square&logo=sitemap)](./01-architecture/architecture-overview.md)
[![🐍 AI推理服务](https://img.shields.io/badge/🐍_AI推理服务-success?style=flat-square&logo=python)](./06-services/python-ai/ai-inference-service.md)
[![📋 快速开始](https://img.shields.io/badge/📋_快速开始-orange?style=flat-square&logo=rocket)](./08-guides/quick-start-guide.md)
[![🚀 部署指南](https://img.shields.io/badge/🚀_部署指南-red?style=flat-square&logo=docker)](./04-deployment/)

</div>

---

*VSS技术文档导航中心 - 最后更新: 2025年7月21日*
