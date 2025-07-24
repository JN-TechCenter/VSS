# 💻 开发环境指南

## 📋 目录概述

本目录包含VSS项目的开发环境搭建和开发流程文档，为开发者提供完整的开发指导。

**目标受众**: 前端开发者、后端开发者、新入职开发者

---

## 📁 文档列表

### 环境搭建文档

| 文档 | 说明 | 状态 |
|------|------|------|
| [开发环境搭建](./development-setup.md) | 本地开发环境配置指南 | ✅ 完成 |
| [Git子模块管理](./git-submodules-guide.md) | Git子模块操作指南 | ✅ 完成 |
| [子模块状态](./submodule-status.md) | 子模块当前状态 | ✅ 完成 |

### 开发流程文档

| 文档 | 说明 | 状态 |
|------|------|------|
| [代码规范](./coding-standards.md) | 代码编写规范 | 📋 计划中 |
| [测试指南](./testing-guide.md) | 单元测试和集成测试 | 📋 计划中 |
| [调试技巧](./debugging-tips.md) | 开发调试技巧 | 📋 计划中 |

### 工具配置文档

| 文档 | 说明 | 状态 |
|------|------|------|
| [IDE配置](./ide-setup.md) | 开发工具配置 | 📋 计划中 |
| [插件推荐](./recommended-plugins.md) | 开发插件推荐 | 📋 计划中 |
| [快捷键指南](./shortcuts-guide.md) | 常用快捷键 | 📋 计划中 |

---

## 🚀 快速开始

### 环境要求

| 工具 | 版本要求 | 说明 |
|------|----------|------|
| **Node.js** | 18+ | 前端开发环境 |
| **Java** | 17+ | 后端开发环境 |
| **Python** | 3.9+ | AI和数据分析服务 |
| **Go** | 1.19+ | 网络服务开发 |
| **Docker** | 20+ | 容器化部署 |
| **Git** | 2.30+ | 版本控制 |

### 一键环境搭建

```bash
# 1. 克隆主项目
git clone --recursive https://github.com/JN-TechCenter/VSS.git
cd VSS

# 2. 运行环境检查脚本
./scripts/check-environment.sh

# 3. 安装依赖
./scripts/install-dependencies.sh

# 4. 启动开发环境
./scripts/start-dev.sh
```

---

## 🏗️ 项目结构

### 主项目结构

```
VSS/
├── 📁 VSS-frontend/          # React前端项目 (子模块)
├── 📁 VSS-backend/           # Java后端项目 (子模块)
├── 📁 inference-server/      # Python AI服务 (子模块)
├── 📁 net-framework-server/  # Go网络服务 (子模块)
├── 📁 data-analysis-server/  # Python数据服务 (子模块)
├── 📁 docs/                  # 项目文档
├── 📁 scripts/               # 管理脚本
├── 📄 docker-compose.yml     # Docker编排文件
├── 📄 .gitmodules            # Git子模块配置
└── 📄 README.md              # 项目说明
```

### 开发分支策略

```mermaid
gitgraph
    commit id: "main"
    branch develop
    checkout develop
    commit id: "feature-base"
    
    branch feature/frontend-ui
    checkout feature/frontend-ui
    commit id: "UI组件开发"
    commit id: "页面集成"
    
    checkout develop
    merge feature/frontend-ui
    
    branch feature/backend-api
    checkout feature/backend-api
    commit id: "API接口开发"
    commit id: "业务逻辑实现"
    
    checkout develop
    merge feature/backend-api
    
    checkout main
    merge develop
    commit id: "v1.0.0"
```

---

## 🔧 开发工具配置

### VS Code配置

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "java.configuration.updateBuildConfiguration": "automatic",
  "python.defaultInterpreterPath": "./venv/bin/python",
  "go.formatTool": "goimports"
}
```

### 推荐插件

#### 前端开发
- **ES7+ React/Redux/React-Native snippets** - React代码片段
- **Prettier - Code formatter** - 代码格式化
- **ESLint** - 代码检查
- **Auto Rename Tag** - 标签自动重命名

#### 后端开发
- **Extension Pack for Java** - Java开发套件
- **Spring Boot Extension Pack** - Spring Boot支持
- **Python** - Python开发支持
- **Go** - Go语言支持

#### 通用工具
- **GitLens** - Git增强工具
- **Docker** - Docker支持
- **REST Client** - API测试工具
- **Thunder Client** - API调试工具

---

## 🧪 测试环境

### 单元测试

```bash
# 前端测试
cd VSS-frontend
npm test

# 后端测试
cd VSS-backend
./mvnw test

# Python AI服务测试
cd inference-server
pytest

# Go网络服务测试
cd net-framework-server
go test ./...

# Python数据服务测试
cd data-analysis-server
python -m pytest
```

### 集成测试

```bash
# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 运行集成测试
./scripts/run-integration-tests.sh

# 清理测试环境
docker-compose -f docker-compose.test.yml down
```

---

## 🔍 调试指南

### 前端调试

```javascript
// React DevTools
// 1. 安装浏览器插件
// 2. 在组件中使用调试

// Redux DevTools
const store = configureStore({
  reducer: rootReducer,
  devTools: process.env.NODE_ENV !== 'production'
});

// 网络请求调试
axios.interceptors.request.use(request => {
  console.log('Starting Request', request);
  return request;
});
```

### 后端调试

```java
// Spring Boot Actuator
// application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus

// 日志配置
logging:
  level:
    com.vss: DEBUG
    org.springframework.web: DEBUG
```

### AI服务调试

```python
# FastAPI调试模式
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,  # 开发模式热重载
        debug=True    # 调试模式
    )

# 模型推理调试
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

def inference(image):
    logger.debug(f"Input image shape: {image.shape}")
    result = model.predict(image)
    logger.debug(f"Inference result: {result}")
    return result
```

---

## 📊 性能监控

### 开发环境监控

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.dev.yml:/etc/prometheus/prometheus.yml
      
  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### 性能指标

| 服务 | 关键指标 | 监控端点 |
|------|----------|----------|
| **Frontend** | 页面加载时间、包大小 | Chrome DevTools |
| **Backend** | 响应时间、内存使用 | `/actuator/metrics` |
| **AI Service** | 推理延迟、GPU使用率 | `/metrics` |
| **Network Service** | 并发连接数、吞吐量 | `/metrics` |
| **Data Service** | 查询时间、数据处理量 | `/metrics` |

---

## 📖 阅读指南

### 🔰 新手开发者
1. 先阅读 [开发环境搭建](./development-setup.md) 配置本地环境
2. 学习 [Git子模块管理](./git-submodules-guide.md) 了解项目结构
3. 参考 [代码规范](./coding-standards.md) 编写代码

### 🏗️ 前端开发者
1. 重点关注React和TypeScript相关配置
2. 掌握前端调试和测试技巧
3. 了解与后端API的集成方式

### ⚙️ 后端开发者
1. 熟悉Spring Boot和微服务架构
2. 掌握数据库设计和API开发
3. 了解容器化部署流程

### 🤖 AI开发者
1. 重点关注Python和AI框架配置
2. 掌握模型训练和推理优化
3. 了解GPU加速和性能监控

---

## 🔗 相关文档

- [系统架构概览](../01-architecture/architecture-overview.md)
- [API设计规范](../02-api-design/README.md)
- [数据库设计](../03-database/README.md)
- [部署运维指南](../04-deployment/README.md)
- [服务详细文档](../06-services/README.md)

---

**📝 最后更新**: 2025年1月 | **👥 维护团队**: 开发团队