# VSS (Vision System Solution)

机器视觉数据分析平台 - 主项目

## 项目结构

- `VSS-frontend/` - React + TypeScript 前端应用
- `VSS-backend/` - Spring Boot 后端服务

## 子模块管理

本项目使用 Git Submodules 来管理前后端子项目：

```bash
# 克隆主项目及所有子模块
git clone --recursive <main-repo-url>

# 如果已经克隆了主项目，需要初始化子模块
git submodule init
git submodule update

# 更新所有子模块到最新版本
git submodule update --remote

# 更新特定子模块
git submodule update --remote VSS-frontend
git submodule update --remote VSS-backend
```

## 开发指南

### 前端开发
```bash
cd VSS-frontend
npm install
npm run dev
```

### 后端开发
```bash
cd VSS-backend
mvn spring-boot:run
```

## 端口配置

- 前端：http://localhost:3000
- 后端：http://localhost:3002
