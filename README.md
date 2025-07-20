# VSS (Vision System Studio)

> **现代化的视觉系统开发平台** - 集成前端、后端和容器化部署的完整解决方案

![VSS](https://img.shields.io/badge/VSS-v1.0-blue.svg)
![Docker](https://img.shields.io/badge/Docker-支持-green.svg)
![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green.svg)

## 🚀 快速开始

### 30秒快速启动

```bash
# Docker 开发环境 (推荐团队使用)
.\docker-manage.bat dev-proxy

# 本地开发环境 (推荐个人使用)  
setup-local-env.bat && start-all.bat

# Docker 生产环境 (推荐部署使用)
.\docker-manage.bat proxy
```

### 🌐 访问应用

- **Docker 模式**: <http://localhost>
- **本地模式**: <http://localhost:8080>
- **前端直连**: <http://localhost:3000> (开发调试)

## 📋 项目概述

VSS 是一个现代化的机器视觉数据分析平台，提供：

- 🎨 **React + TypeScript** 现代化前端界面
- ⚙️ **Spring Boot** 企业级后端服务  
- 🐳 **Docker** 一键容器化部署
- 🔥 **热更新** 极速开发体验
- 🌐 **Nginx** 高性能反向代理
- 📱 **响应式** 移动端适配

## 🏗️ 技术架构

### 前端技术栈
- **React 18** - 用户界面框架
- **TypeScript** - 类型安全开发
- **Vite** - 极速构建工具  
- **Tailwind CSS** - 原子化样式

### 后端技术栈
- **Spring Boot 3.x** - Java 企业级框架
- **Spring Data JPA** - 数据持久化
- **Maven** - 项目管理工具
- **RESTful API** - 标准接口设计

### 基础设施
- **Docker & Docker Compose** - 容器化部署
- **Nginx** - 反向代理 + 静态文件服务
- **PostgreSQL** - 生产级数据库

## 📁 项目结构

```text
VSS/
├── 📄 README.md                    # 项目说明文档  
├── � docker-compose*.yml          # Docker 编排配置
├── 📁 scripts/                     # 管理脚本集合
│   ├── �🐳 docker-manage.bat        # Docker 管理脚本
│   ├── ⚙️ install-local-env.bat    # 本地环境安装脚本
│   ├── � quick-start.bat          # 一键启动脚本
│   └── 📖 README.md               # 脚本使用说明
├── 📁 config/                      # 环境配置文件
│   ├── .env                        # 基础环境变量
│   ├── .env.proxy                  # 代理模式配置
│   └── 📖 README.md               # 配置说明文档
├── 📁 nginx/                       # Web服务器配置
│   ├── nginx.conf                  # 生产环境配置
│   ├── nginx-dev.conf              # 开发环境配置
│   └── 📖 README.md               # Nginx配置说明
├── 📚 docs/                        # 📁 文档中心
│   ├── SETUP-GUIDE.md             # 完整配置指南
│   ├── QUICK-REFERENCE.md          # 快速参考手册
│   ├── COMMANDS.md                 # 命令速查表
│   └── DOCS-INDEX.md               # 文档导航中心
├── ⚙️ config/                      # 配置文件目录
│   ├── README.md                  # 配置文件说明
│   ├── .env                       # 基础环境变量
│   ├── .env.proxy                 # 生产代理配置
│   └── .env.dev-proxy             # 开发代理配置
├── 🌐 nginx/                       # Nginx 配置目录
│   ├── README.md                  # Nginx 配置说明
│   ├── nginx.conf                 # 生产环境配置
│   ├── nginx-dev.conf             # 开发环境配置
│   ├── nginx-local.conf           # 本地开发配置
│   └── conf.d/                    # 额外配置目录
├── 🎨 VSS-frontend/                # React 前端项目
│   ├── src/                       # 前端源代码
│   ├── package.json               # npm 依赖配置
│   ├── vite.config.ts             # Vite 构建配置
│   └── Dockerfile*                # 容器构建文件
└── ⚙️ VSS-backend/                 # Spring Boot 后端
    ├── src/main/java/             # Java 源代码
    ├── src/main/resources/        # 配置资源文件
    ├── pom.xml                    # Maven 项目配置
    └── Dockerfile                 # 容器构建文件
```

## 🎯 部署模式选择

| 模式 | 命令 | 适用场景 | 热更新 | 端口 |
|------|------|----------|--------|------|
| **Docker 开发** | `scripts\docker-manage.bat dev-proxy` | 团队协作开发 | ✅ | 80 |
| **Docker 生产** | `scripts\docker-manage.bat proxy` | 生产环境部署 | ❌ | 80 |
| **本地开发** | `scripts\install-local-env.bat` | 个人开发调试 | ✅ | 8080 |

## 🔧 开发指南

### 环境要求

- **Node.js** 18+ (前端开发)
- **Java** 17+ (后端开发)  
- **Docker Desktop** (容器化部署)
- **Git** 2.0+ (版本控制)

### 快速开始开发

1. **克隆项目**

   ```bash
   git clone https://github.com/JN-TechCenter/VSS.git
   cd VSS
   ```

2. **选择开发模式**

   ```bash
   # Docker 团队开发 (推荐)
   scripts\docker-manage.bat dev-proxy
   
   # 一键快速启动 (新用户推荐)
   scripts\quick-start.bat
   
   # 本地个人开发 (可选)
   scripts\install-local-env.bat
   ```

3. **开始编码**

   - 修改 `VSS-frontend/src/` 前端代码
   - 修改 `VSS-backend/src/` 后端代码  
   - 保存后自动热更新 ⚡

### 常用开发命令

```bash
# 查看服务状态
scripts\docker-manage.bat status

# 查看实时日志  
scripts\docker-manage.bat logs [service-name]

# 重启所有服务
scripts\docker-manage.bat restart

# 重新构建镜像
scripts\docker-manage.bat build

# 清理Docker资源
scripts\docker-manage.bat clean
```

## 📚 完整文档

### 📖 主要文档 (优先阅读)

- **[📖 详细配置指南](./docs/SETUP-GUIDE.md)** - 新手必读的完整安装配置教程
- **[⚡ 快速参考手册](./docs/QUICK-REFERENCE.md)** - 5分钟上手的核心操作指南  
- **[📋 命令速查表](./docs/COMMANDS.md)** - 日常开发必备的命令对照表
- **[🧭 文档导航中心](./docs/DOCS-INDEX.md)** - 快速找到所需文档的入口

### 📝 过程文档说明 (可跳过)

> **⚠️ 重要提醒**: 
> - 大写命名的 `.md` 文件 (如 `ENCODING-FIX-GUIDE.md`) 通常是**过程记录**和**临时解决方案**
> - 这些文档记录了开发过程中遇到的具体问题和解决步骤
> - **AI 模型**建议**跳过**这类文档，专注于上述主要文档，以保持问题聚焦

## 🐛 故障排除

### 常见问题快速解决

| 问题症状 | 快速解决方案 |
|----------|--------------|
| 🚫 端口冲突 | `netstat -ano \| findstr :3000` 找到进程并结束 |
| 🐳 容器启动失败 | `docker logs [容器名]` 查看详细错误日志 |
| 🔥 热更新不工作 | 浏览器 F12 → Network → WS 检查连接 |
| 🌐 Nginx 502错误 | `docker restart vss-nginx` 重启代理服务 |

💡 **更多解决方案**: 查看 [故障排除指南](./docs/SETUP-GUIDE.md#故障排除指南)

## 🤝 参与贡献

我们欢迎社区贡献！参与步骤：

1. **Fork** 本仓库到您的 GitHub
2. **创建** 特性分支 (`git checkout -b feature/AmazingFeature`)  
3. **提交** 您的修改 (`git commit -m 'Add: 添加了令人惊艳的功能'`)
4. **推送** 到分支 (`git push origin feature/AmazingFeature`)
5. **提交** Pull Request

## 📋 Git 管理策略

本项目采用 **多仓库管理** 模式：

- **主仓库** (本仓库): 项目文档、配置、整体协调
- **前端子仓库**: 独立的 React 项目和版本管理  
- **后端子仓库**: 独立的 Spring Boot 项目和版本管理

### ✅ 优势特点

- 🔄 各子项目保持独立的提交历史
- 🔐 可针对不同模块设置不同权限
- 🚀 便于持续集成和独立部署  
- 👥 团队成员可专注特定技术栈

### 🔄 同步更新操作

```bash
# 更新主仓库配置
git pull origin main

# 更新前端子项目
cd VSS-frontend && git pull origin main

# 更新后端子项目  
cd VSS-backend && git pull origin main
```

## 🌐 服务端口配置

| 服务 | 端口 | 说明 |
|------|------|------|
| Nginx 代理 | 80 | Docker 模式主入口 |
| 本地代理 | 8080 | 本地开发主入口 |
| 前端开发 | 3000 | React 开发服务器 |
| 后端 API | 3000 | Spring Boot 服务 |
| HMR 热更新 | 24678 | Vite 热更新通道 |

## 🚀 生产部署

### Docker 生产部署 (推荐)

```bash
# 一键生产部署
.\docker-manage.bat proxy

# 访问应用
curl http://localhost
```

### 传统部署方式

**前端构建部署:**

```bash
cd VSS-frontend
npm run build
# 将 dist/ 目录部署到 Web 服务器
```

**后端构建部署:**

```bash
cd VSS-backend  
mvn clean package
# 部署 target/*.jar 到应用服务器
```

## 📄 开源许可

本项目采用 **MIT License** - 详见 [LICENSE](LICENSE) 文件

## 📞 联系方式

- **📂 项目仓库**: [VSS GitHub Repository](https://github.com/JN-TechCenter/VSS)
- **🐛 问题反馈**: [GitHub Issues](https://github.com/JN-TechCenter/VSS/issues)  
- **📖 技术文档**: [项目 Wiki](https://github.com/JN-TechCenter/VSS/wiki)
- **💬 讨论交流**: [GitHub Discussions](https://github.com/JN-TechCenter/VSS/discussions)

## 🏆 致谢

感谢所有为 VSS 项目贡献代码、文档、测试和反馈的开发者们！

[![Contributors](https://contrib.rocks/image?repo=JN-TechCenter/VSS)](https://github.com/JN-TechCenter/VSS/graphs/contributors)

---

*📅 最后更新: 2025-07-20 | 🏷️ 版本: v1.0 | ⭐ 如果这个项目对您有帮助，请点个 Star！*
