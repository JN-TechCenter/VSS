# VSS (Vision System Solution)

机器视觉数据分析平台 - 主项目

## 项目结构

- `VSS-frontend/` - React + TypeScript 前端应用
- `VSS-backend/` - Spring Boot 后端服务
- `VSS.code-workspace` - VS Code 工作区配置文件

## 开发环境设置

### 方法1：使用 VS Code 工作区（推荐）
```bash
# 在 VS Code 中打开工作区文件
code VSS.code-workspace
```

这将在 VS Code 中同时打开前后端项目，每个项目保持独立的 Git 仓库。

### 方法2：分别克隆和开发
```bash
# 前端开发
cd VSS-frontend
npm install
npm run dev

# 后端开发  
cd VSS-backend
mvn clean compile
mvn spring-boot:run
```

## Git 管理策略

本项目采用 **多仓库管理** 方式：

- 主仓库（本仓库）：管理项目文档、配置和整体协调
- 前端子仓库：独立管理前端代码和版本
- 后端子仓库：独立管理后端代码和版本

### 优势
- ✅ 各子项目保持独立的提交历史
- ✅ 可以针对不同项目设置不同的权限
- ✅ 便于持续集成和独立部署
- ✅ 团队可以专注于特定技术栈

### 同步更新
```bash
# 更新主仓库
git pull origin main

# 更新前端
cd VSS-frontend
git pull origin main

# 更新后端  
cd VSS-backend
git pull origin main
```

## 服务端口

- 前端开发服务器：<http://localhost:3000>
- 后端API服务：<http://localhost:3002>

## 部署说明

### 前端部署
```bash
cd VSS-frontend
npm run build
# 将 dist/ 目录部署到 Web 服务器
```

### 后端部署
```bash
cd VSS-backend
mvn clean package
# 部署 target/vision-platform-backend-0.0.1-SNAPSHOT.jar
```
