# Git Submodules Configuration for VSS Project

## 🎯 子仓库管理策略

VSS项目采用**主仓库 + 子仓库**的模式，实现模块化开发和独立CI/CD。

### 📦 子仓库列表

| 子仓库 | 路径 | 分支 | 负责团队 | 说明 |
|--------|------|------|----------|------|
| `yolo_inference_server` | `./yolo_inference_server/` | `main` | Python AI团队 | YOLO模型推理服务 |
| `VSS-frontend` | `./VSS-frontend/` | `main` | 前端团队 | React前端应用 |
| `VSS-backend` | `./VSS-backend/` | `main` | Java团队 | Spring Boot后端 |

### 🔧 子模块操作命令

#### 1. 初始化所有子模块
```bash
# 初始化并更新所有子模块
git submodule update --init --recursive

# 或者克隆时同时初始化子模块
git clone --recurse-submodules https://github.com/JN-TechCenter/VSS.git
```

#### 2. 添加新的子模块
```bash
# 添加YOLO推理服务子模块
git submodule add https://github.com/JN-TechCenter/yolo_inference_server.git yolo_inference_server

# 提交子模块配置
git add .gitmodules yolo_inference_server
git commit -m "Add: 添加YOLO推理服务子模块"
```

#### 3. 更新子模块
```bash
# 更新所有子模块到最新版本
git submodule update --remote --recursive

# 更新特定子模块
git submodule update --remote yolo_inference_server

# 进入子模块目录进行独立开发
cd yolo_inference_server
git checkout main
git pull origin main
```

#### 4. 子模块开发流程
```bash
# 1. 进入子模块目录
cd yolo_inference_server

# 2. 创建功能分支
git checkout -b feature/new-yolo-model

# 3. 开发和提交
git add .
git commit -m "Add: 新增YOLOv8模型支持"
git push origin feature/new-yolo-model

# 4. 合并到主分支后，回到主仓库更新
cd ..
git add yolo_inference_server
git commit -m "Update: 更新YOLO推理服务到最新版本"
```

### 🚀 持续集成配置

#### Docker Compose集成
```yaml
# docker-compose.yml 中的子仓库服务
yolo-inference:
  build:
    context: ./yolo_inference_server  # 子仓库路径
    dockerfile: Dockerfile
  container_name: vss-yolo-inference
```

#### GitHub Actions示例
```yaml
# .github/workflows/ci.yml
name: VSS CI/CD Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test-yolo-service:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive  # 自动拉取子模块
      
      - name: Test YOLO Inference Service
        run: |
          cd yolo_inference_server
          docker build -t yolo-test .
          docker run --rm yolo-test python -m pytest
```

### 📋 最佳实践

#### 1. 版本管理
- **主仓库**: 记录子模块的特定commit hash
- **子仓库**: 独立的版本标签和发布
- **兼容性**: 主仓库指定兼容的子模块版本

#### 2. 开发流程
- **功能开发**: 在子仓库中独立开发
- **集成测试**: 在主仓库中测试整体集成
- **版本发布**: 先发布子仓库，再更新主仓库

#### 3. 团队协作
- **权限管理**: 不同团队对不同子仓库有相应权限
- **独立CI/CD**: 每个子仓库有独立的CI/CD流水线
- **文档同步**: 主仓库维护整体文档，子仓库维护技术文档

### 🔄 自动化脚本

#### 更新所有子模块脚本
```bash
#!/bin/bash
# scripts/update-submodules.sh

echo "🔄 更新所有子模块..."

# 更新子模块
git submodule update --remote --recursive

# 检查是否有更新
if git diff --quiet HEAD -- $(git submodule status | awk '{print $2}'); then
    echo "✅ 所有子模块都是最新版本"
else
    echo "📦 发现子模块更新，准备提交..."
    git add .
    git commit -m "Update: 自动更新所有子模块到最新版本"
    echo "✅ 子模块更新已提交"
fi
```

### 🛠️ 故障排除

#### 常见问题
1. **子模块目录为空**: 运行 `git submodule update --init`
2. **子模块版本冲突**: 检查 `.gitmodules` 配置
3. **权限问题**: 确保对子仓库有访问权限

#### 重置子模块
```bash
# 完全重置所有子模块
git submodule deinit --all -f
git submodule update --init --recursive
```

---

*VSS Git子模块管理文档 - 最后更新: 2025年7月21日*
