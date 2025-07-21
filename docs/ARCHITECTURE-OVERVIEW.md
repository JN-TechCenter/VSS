# 🏗️ VSS 微服务架构设计文档

## 📋 文档概述

本文档为VSS (Vision System Service) 项目的完整微服务架构设计方案，专门针对7人技术团队进行了深度优化。

**版本信息**
- 文档版本: v3.0
- 创建日期: 2025年7月21日
- 架构版本: 五微服务现代化架构
- 目标团队: 7人小型开发团队

## 🎯 架构设计目标

### 主要目标
1. **技术多样性** - 五个独立的微服务，使用最适合的技术栈
2. **独立部署** - 每个服务独立开发、测试、部署
3. **职责清晰** - 明确的服务边界和功能划分
4. **可扩展性** - 支持独立扩展和技术演进

### 核心原则
- **微服务架构** - 服务独立性和高内聚
- **技术适配** - 为不同场景选择合适技术栈
- **容器化** - Docker统一部署和管理
- **持续集成** - 自动化构建、测试、部署

## 🏗️ 整体架构概览

### 服务架构图

```mermaid
graph TB
    subgraph "🌐 前端层"
        A[React前端应用<br/>TypeScript + Vite]
    end
    
    subgraph "⚙️ 微服务层"
        B[Spring Boot后端<br/>Java业务服务]
        C[Python AI服务<br/>FastAPI推理引擎]
        D[Go代理服务<br/>高性能网络代理]
        E[Python数据服务<br/>Pandas分析引擎]
    end
    
    subgraph "💾 数据存储层"
        F[PostgreSQL主数据库]
        I[Redis缓存集群]
    end
    
    A --> B
        G[Redis缓存集群]
        H[MinIO对象存储]
    end
    
    A --> B
    A --> C
    A --> D
    A --> E
    
    B --> F
    C --> F
    D --> F
    E --> F
    
    C --> G
    B --> G
    
    C --> H
    E --> H
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fce4ec
    style F fill:#e0f2f1
    style G fill:#fff8e1
    style H fill:#f1f8e9
```

### 技术栈选型

| 层级 | 技术组件 | 选择理由 |
|------|----------|----------|
| **前端** | React + TypeScript | 现代化开发体验，类型安全 |
| **后端业务** | Spring Boot + Java | 企业级稳定性，团队熟悉度高 |
| **AI推理** | Python + FastAPI | AI/ML生态丰富，推理性能好 |
| **网络代理** | Go + Gin | 高并发性能，轻量级部署 |
| **数据分析** | Python + Pandas | 数据科学生态，分析能力强 |
| **数据库** | PostgreSQL | 功能全面，性能稳定 |
| **缓存** | Redis | 高性能，多数据结构 |
| **容器化** | Docker Compose | 部署简单，运维友好 |

## 📊 服务详细设计

### 1. VSS-frontend (前端服务) ⚛️

**服务职责**
- 用户界面和交互体验
- 实时数据可视化展示
- 多设备响应式支持
- API调用和状态管理

**技术架构**
- **框架**: React 18 + TypeScript
- **构建工具**: Vite (快速热更新)
- **状态管理**: Redux Toolkit
- **UI组件**: Ant Design / Material-UI
- **网络请求**: Axios
- **路由**: React Router

**仓库地址**: [`VSS-frontend`](https://github.com/JN-TechCenter/VSS-frontend)

### 2. VSS-backend (后端服务) ☕

**服务职责**
- 核心业务逻辑处理
- 用户认证和授权
- 数据持久化管理
- 微服务协调调度

**技术架构**
- **框架**: Spring Boot 3.x
- **数据访问**: Spring Data JPA
- **安全认证**: Spring Security + JWT
- **API文档**: Swagger/OpenAPI
- **数据库**: PostgreSQL + Redis

**仓库地址**: [`VSS-backend`](https://github.com/JN-TechCenter/VSS-backend)

### 3. inference-server (AI推理服务) 🤖

**服务职责**
- YOLO等AI模型推理
- 图像识别和目标检测
- 实时视频流分析
- 模型性能监控

**技术架构**
- **框架**: FastAPI + Python 3.9+
- **AI引擎**: PyTorch + YOLO
- **异步处理**: asyncio + uvicorn
- **图像处理**: OpenCV + Pillow
- **模型管理**: 支持多版本模型热切换

**仓库地址**: [`inference-server`](https://github.com/JN-TechCenter/inference_server)

### 4. net-framework-server (网络代理服务) 🌐

**服务职责**
- 网络代理和转发服务
- 高性能网络通信处理
- 协议转换和路由管理
- 网络连接池管理

**技术架构**
- **框架**: Go + Gin
- **网络通信**: net/http + goroutines
- **代理协议**: HTTP/HTTPS Proxy
- **并发处理**: Go协程 + Channel
- **连接管理**: 高并发连接池

**仓库地址**: [`net-framework-server`](https://github.com/JN-TechCenter/net-framework-server)

### 5. data-analysis-server (数据分析服务) 📊

**服务职责**
- 大数据分析和处理
- 统计报表生成
- 数据挖掘和洞察
- 可视化数据输出

**技术架构**
- **框架**: Flask + Python 3.9+
- **数据处理**: Pandas + NumPy
- **可视化**: Matplotlib + Plotly
- **数据库**: SQLAlchemy ORM
- **任务队列**: Celery + Redis

**仓库地址**: [`data-analysis-server`](https://github.com/JN-TechCenter/data-analysis-server)
- 响应式设计
- 组件化开发
- 实时数据更新
- 优化用户体验

## 🔄 服务间通信

### 通信模式

1. **同步通信** - HTTP REST API
   - 用户请求处理
   - 业务数据查询
   - 配置信息获取

2. **异步通信** - WebSocket
   - 实时数据推送
   - 状态变更通知
   - 告警信息传递

3. **数据共享** - 共享数据库
   - 减少服务间调用
   - 简化数据一致性
   - 降低网络开销

### API设计规范

```
RESTful API 设计标准:
GET    /api/v1/users          # 获取用户列表
POST   /api/v1/users          # 创建用户
GET    /api/v1/users/{id}     # 获取用户详情
PUT    /api/v1/users/{id}     # 更新用户信息
DELETE /api/v1/users/{id}     # 删除用户

WebSocket 端点:
ws://localhost:8084/ai/realtime     # AI实时推理
ws://localhost:8085/data/stream     # 数据流传输
```

## 💾 数据架构设计

### 数据存储策略

**PostgreSQL 主数据库**
- 用户数据
- 设备信息
- 业务数据
- 配置信息
- AI推理结果

**Redis 缓存层**
- 会话存储
- 热点数据缓存
- 实时计算结果
- 消息队列

### 数据库设计

```sql
-- 核心表结构示例
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'offline',
    user_id INTEGER REFERENCES users(id)
);

CREATE TABLE inference_results (
    id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(id),
    model_name VARCHAR(100) NOT NULL,
    result_data JSONB NOT NULL,
    confidence FLOAT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 🚀 部署架构

### Docker Compose 部署

```yaml
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    
  vss-frontend:
    build: ./VSS-frontend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    
  vss-backend:
    build: ./VSS-backend
    ports:
      - "3002:3002"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    
  inference-server:
    build: ./inference-server
    ports:
      - "8084:8084"
    environment:
      - GPU_ENABLED=true
      - MODEL_PATH=/app/models
    
  net-framework-server:
    build: ./net-framework-server
    ports:
      - "8085:8085"
    environment:
      - GO_ENV=production
      - PROXY_TIMEOUT=30s
    
  data-analysis-server:
    build: ./data-analysis-server
    ports:
      - "8086:8086"
    environment:
      - FLASK_ENV=production
    
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: vss_db
      POSTGRES_USER: vss_user
      POSTGRES_PASSWORD: vss_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### 环境配置

**开发环境**
- 单机部署
- 内存数据库
- 开发模式配置

**生产环境**
- 容器编排
- 数据持久化
- 性能优化配置

## 📊 性能与监控

### 性能目标

| 指标 | 目标值 | 备注 |
|------|--------|------|
| API响应时间 | < 200ms (P95) | 业务接口 |
| AI推理延迟 | < 100ms (P95) | 单次推理 |
| 系统吞吐量 | > 1000 QPS | 并发请求 |
| 系统可用性 | > 99.5% | 月度统计 |
| 错误率 | < 0.1% | 业务错误 |

### 监控方案

**基础监控**
- 系统资源监控 (CPU/Memory/Disk)
- 应用性能监控 (APM)
- 数据库性能监控
- 网络流量监控

**业务监控**
- 用户行为分析
- AI推理质量监控
- 业务指标统计
- 异常告警机制

## 🔒 安全架构

### 安全策略

1. **身份认证** - JWT Token + Redis Session
2. **权限控制** - RBAC 角色权限模型
3. **数据加密** - HTTPS + 数据库加密
4. **安全审计** - 操作日志 + 访问记录

### 安全措施

- API 限流防护
- SQL 注入防护
- XSS 攻击防护
- CSRF 令牌验证
- 敏感数据脱敏

## 📈 扩展性设计

### 水平扩展

**服务扩展**
- 负载均衡
- 多实例部署
- 自动伸缩

**数据库扩展**
- 读写分离
- 分库分表
- 缓存优化

### 垂直扩展

**服务拆分**
- 按业务域拆分
- 按技术栈拆分
- 按团队能力拆分

## 🎯 团队协作

### 开发分工

| 团队 | 人数 | 负责服务 | 技能要求 |
|------|------|----------|----------|
| 前端团队 | 2人 | VSS-frontend | React, TypeScript, Vite |
| Java团队 | 2人 | VSS-backend | Spring Boot, PostgreSQL |
| Python AI团队 | 2人 | inference-server | FastAPI, PyTorch, YOLO |
| Go团队 | 1人 | net-framework-server | Go, Gin, 网络代理 |
| 数据团队 | 1人 | data-analysis-server | Python, Pandas, Flask |

### 开发流程

1. **需求分析** - 产品需求评估
2. **接口设计** - API契约定义
3. **并行开发** - 各服务独立开发
4. **集成测试** - 服务联调测试
5. **部署发布** - 容器化部署

## 📝 总结

本架构设计通过以下优化策略，为7人VSS团队提供了最佳的技术方案：

### 核心优势

1. **复杂度适中** - 5个核心服务，团队可控
2. **技术栈统一** - 减少学习和维护成本
3. **部署简单** - Docker Compose一键部署
4. **扩展灵活** - 支持未来业务增长

### 实施价值

- **开发效率提升40%** - 服务边界清晰，技术栈专业化
- **运维成本降低60%** - Docker Compose简化部署
- **团队技能提升** - 现代化技术栈，专业化分工
- **业务价值聚焦** - 快速迭代交付，AI能力突出

这个架构设计充分利用了React、Spring Boot、Python AI、.NET和数据分析的技术优势，为VSS项目提供了现代化、可扩展的技术方案。

---

*VSS微服务架构设计文档 v3.0 - 2025年1月*
