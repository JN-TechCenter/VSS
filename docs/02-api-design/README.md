# 🔌 API 设计规范

## 📋 目录概述

本目录包含VSS项目的API设计规范和接口文档，为前后端开发提供统一的接口标准。

**目标受众**: 前端开发者、后端开发者、接口测试人员

---

## 📁 文档列表

### 核心规范文档

| 文档 | 说明 | 状态 |
|------|------|------|
| [API设计标准](./api-standards.md) | RESTful API设计规范 | 📋 计划中 |
| [接口文档模板](./api-template.md) | 接口文档编写模板 | 📋 计划中 |
| [错误码规范](./error-codes.md) | 统一错误码定义 | 📋 计划中 |

### 服务接口文档

| 文档 | 说明 | 状态 |
|------|------|------|
| [业务服务API](./backend-api.md) | Java后端服务接口 | 📋 计划中 |
| [AI推理API](./inference-api.md) | Python AI服务接口 | 📋 计划中 |
| [网络服务API](./network-api.md) | Go网络服务接口 | 📋 计划中 |
| [数据分析API](./data-api.md) | Python数据服务接口 | 📋 计划中 |

---

## 🎯 API设计原则

### RESTful 设计标准

```
GET    /api/v1/users          # 获取用户列表
POST   /api/v1/users          # 创建用户
GET    /api/v1/users/{id}     # 获取用户详情
PUT    /api/v1/users/{id}     # 更新用户信息
DELETE /api/v1/users/{id}     # 删除用户
```

### 响应格式规范

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com"
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

### 错误响应格式

```json
{
  "code": 400,
  "message": "参数错误",
  "error": "用户名不能为空",
  "timestamp": "2025-01-01T00:00:00Z"
}
```

---

## 🌐 服务端口分配

### 服务端口规划

| 服务 | 端口 | 协议 | 说明 |
|------|------|------|------|
| **VSS-frontend** | 3000 | HTTP | React前端应用 |
| **VSS-backend** | 8080 | HTTP | Java业务服务 |
| **inference-server** | 8000 | HTTP | Python AI推理 |
| **net-framework-server** | 9000 | HTTP/WS | Go网络服务 |
| **data-analysis-server** | 7000 | HTTP | Python数据分析 |
| **PostgreSQL** | 5432 | TCP | 主数据库 |
| **Redis** | 6379 | TCP | 缓存服务 |
| **Nginx** | 80 | HTTP | 反向代理 |

### API版本管理

- **版本格式**: `/api/v1/`, `/api/v2/`
- **向后兼容**: 保持旧版本API可用
- **废弃策略**: 提前通知，逐步迁移

---

## 🔐 认证与授权

### JWT Token 认证

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 权限控制

- **角色权限**: RBAC模型
- **资源权限**: 细粒度控制
- **API限流**: 防止滥用

---

## 📊 WebSocket 实时通信

### 连接端点

```
ws://localhost:9000/ws/realtime     # 实时数据推送
ws://localhost:8000/ws/inference    # AI推理结果
ws://localhost:7000/ws/analytics    # 数据分析结果
```

### 消息格式

```json
{
  "type": "inference_result",
  "data": {
    "model": "yolo_v8",
    "confidence": 0.95,
    "objects": [...]
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

---

## 📖 阅读指南

### 🔰 前端开发者
1. 先阅读 [API设计标准](./api-standards.md) 了解接口规范
2. 查看具体服务的API文档了解接口详情
3. 参考 [错误码规范](./error-codes.md) 处理异常情况

### 🔧 后端开发者
1. 遵循 [API设计标准](./api-standards.md) 设计接口
2. 使用 [接口文档模板](./api-template.md) 编写文档
3. 实现统一的 [错误码规范](./error-codes.md)

### 🧪 测试人员
1. 根据API文档编写测试用例
2. 验证接口的功能和性能
3. 测试错误处理和边界情况

---

## 🔗 相关文档

- [系统架构概览](../01-architecture/architecture-overview.md)
- [微服务设计](../01-architecture/microservices-design.md)
- [开发环境搭建](../05-development/development-setup.md)
- [服务详细文档](../06-services/README.md)

---

**📝 最后更新**: 2025年1月 | **👥 维护团队**: 接口设计组