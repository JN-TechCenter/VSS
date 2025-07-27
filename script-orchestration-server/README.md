# VSS 脚本编排服务

## 📋 概述

VSS脚本编排服务是VSS视觉监控平台的核心组件之一，提供强大的脚本管理、执行和监控功能。支持Python和Bash脚本的创建、编辑、执行和调度。

## 🚀 主要功能

### 1. 脚本管理
- ✅ 脚本创建、编辑、删除
- ✅ 脚本版本管理
- ✅ 脚本分类和标签
- ✅ 脚本状态管理（草稿、激活、停用、归档）

### 2. 脚本执行
- ✅ 手动执行
- ✅ 定时执行（Cron表达式）
- ✅ 事件触发执行
- ✅ API触发执行
- ✅ 执行超时控制
- ✅ 重试机制

### 3. 执行监控
- ✅ 实时执行状态监控
- ✅ 执行日志记录
- ✅ 执行历史查询
- ✅ 性能统计分析

### 4. 脚本模板
- ✅ 内置脚本模板
- ✅ 自定义模板创建
- ✅ 模板参数化
- ✅ 模板共享

### 5. 可视化设计器
- 🔄 拖拽式脚本设计
- 🔄 工作流编排
- 🔄 条件分支
- 🔄 并行执行

## 🏗️ 技术架构

### 后端技术栈
- **框架**: FastAPI 0.104.1
- **数据库**: PostgreSQL (通过SQLAlchemy)
- **任务调度**: APScheduler
- **缓存**: Redis
- **异步处理**: asyncio

### 核心组件
```
script-orchestration-server/
├── app/
│   ├── api/v1/          # API路由
│   ├── core/            # 核心配置
│   ├── models/          # 数据模型
│   ├── schemas/         # Pydantic模式
│   ├── services/        # 业务逻辑
│   └── utils/           # 工具类
├── main.py              # 应用入口
├── requirements.txt     # 依赖文件
└── Dockerfile          # 容器配置
```

## 📊 API接口

### 脚本管理
- `POST /api/v1/scripts/` - 创建脚本
- `GET /api/v1/scripts/` - 获取脚本列表
- `GET /api/v1/scripts/{id}` - 获取脚本详情
- `PUT /api/v1/scripts/{id}` - 更新脚本
- `DELETE /api/v1/scripts/{id}` - 删除脚本

### 脚本执行
- `POST /api/v1/scripts/{id}/execute` - 执行脚本
- `GET /api/v1/scripts/{id}/executions` - 获取脚本执行记录
- `GET /api/v1/scripts/executions/` - 获取所有执行记录
- `GET /api/v1/scripts/executions/{execution_id}` - 获取执行详情
- `POST /api/v1/scripts/executions/{execution_id}/cancel` - 取消执行

### 脚本模板
- `POST /api/v1/scripts/templates/` - 创建模板
- `GET /api/v1/scripts/templates/` - 获取模板列表

### 统计信息
- `GET /api/v1/scripts/statistics/overview` - 获取统计概览

## 🔧 配置说明

### 环境变量
```bash
# 数据库配置
DATABASE_URL=postgresql://vss_user:vss_password@vss-database:5432/vss_db

# Redis配置
REDIS_URL=redis://vss-redis:6379/2

# 服务配置
PORT=8087
DEBUG=true

# 脚本执行配置
SCRIPT_TIMEOUT=300
MAX_CONCURRENT_SCRIPTS=10
SCRIPT_STORAGE_PATH=/app/scripts
```

### 数据库表结构
- `scripts` - 脚本信息表
- `script_executions` - 脚本执行记录表
- `script_templates` - 脚本模板表
- `workflow_nodes` - 工作流节点表
- `workflow_edges` - 工作流连接表

## 🚀 快速开始

### 1. Docker部署
```bash
# 构建镜像
docker build -t vss-script-orchestration-server .

# 运行容器
docker run -d \
  --name vss-script-orchestration-server \
  -p 8087:8087 \
  -e DATABASE_URL=postgresql://vss_user:vss_password@vss-database:5432/vss_db \
  -e REDIS_URL=redis://vss-redis:6379/2 \
  vss-script-orchestration-server
```

### 2. 本地开发
```bash
# 安装依赖
pip install -r requirements.txt

# 启动服务
python main.py
```

### 3. 访问服务
- **API文档**: http://localhost:8087/docs
- **健康检查**: http://localhost:8087/health

## 📝 使用示例

### 创建Python脚本
```python
import requests

script_data = {
    "name": "Hello World",
    "description": "简单的Hello World脚本",
    "category": "example",
    "content": "print('Hello, World!')",
    "language": "python",
    "timeout": 60
}

response = requests.post(
    "http://localhost:8087/api/v1/scripts/",
    json=script_data
)
```

### 执行脚本
```python
script_id = 1
execution_data = {
    "input_parameters": {"name": "VSS"},
    "environment_vars": {"ENV": "production"}
}

response = requests.post(
    f"http://localhost:8087/api/v1/scripts/{script_id}/execute",
    json=execution_data
)
```

### 查询执行结果
```python
execution_id = "uuid-string"
response = requests.get(
    f"http://localhost:8087/api/v1/scripts/executions/{execution_id}"
)
```

## 🔒 安全特性

### 脚本安全
- ✅ 脚本语法验证
- ✅ 危险命令检测
- ✅ 执行超时控制
- ✅ 资源使用限制

### 访问控制
- ✅ API认证
- ✅ 权限验证
- ✅ 操作日志记录

## 📈 监控指标

### 性能指标
- 脚本执行成功率
- 平均执行时间
- 并发执行数量
- 资源使用情况

### 业务指标
- 脚本总数
- 活跃脚本数
- 执行总次数
- 模板使用统计

## 🔄 集成说明

### 与其他服务集成
- **后端服务**: 用户认证和权限管理
- **AI推理服务**: 模型推理脚本执行
- **数据分析服务**: 数据处理脚本执行
- **前端服务**: 可视化脚本管理界面

### Nginx代理配置
```nginx
location /scripts/ {
    proxy_pass http://vss-script-orchestration-server:8087/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## 🐛 故障排除

### 常见问题
1. **脚本执行失败**
   - 检查脚本语法
   - 验证环境变量
   - 查看执行日志

2. **连接数据库失败**
   - 检查数据库连接字符串
   - 验证数据库服务状态
   - 检查网络连接

3. **调度器启动失败**
   - 检查Redis连接
   - 验证调度器配置
   - 查看服务日志

### 日志查看
```bash
# 查看容器日志
docker logs vss-script-orchestration-server

# 查看应用日志
tail -f logs/script-orchestration.log
```

## 📚 开发指南

### 添加新的脚本类型
1. 在`ScriptService`中添加执行方法
2. 更新脚本验证器
3. 添加相应的模板

### 扩展API接口
1. 在`schemas`中定义数据模式
2. 在`services`中实现业务逻辑
3. 在`api`中添加路由

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 📄 许可证

本项目采用MIT许可证。

---

> 💡 **提示**: 这是VSS视觉监控平台的脚本编排服务，为整个平台提供自动化脚本管理和执行能力。