#!/bin/bash

# VSS项目构建状态检查脚本

echo "🚀 VSS项目状态检查"
echo "=================="

# 检查Docker是否运行
if docker info >/dev/null 2>&1; then
    echo "✅ Docker正在运行"
else
    echo "❌ Docker未运行"
    exit 1
fi

# 检查Docker镜像
echo -e "\n📦 Docker镜像状态:"
docker images | grep -E "(vss-|postgres|nginx)" || echo "   暂无VSS相关镜像"

# 检查运行中的容器
echo -e "\n🏃 运行中的容器:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep -E "(vss-|postgres|nginx)" || echo "   暂无VSS相关容器运行"

# 检查所有容器（包括停止的）
echo -e "\n📋 所有VSS容器:"
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | grep -E "(vss-|postgres|nginx)" || echo "   暂无VSS相关容器"

# 检查Docker Compose状态
echo -e "\n🔧 Docker Compose状态:"
if [ -f "docker-compose.yml" ]; then
    docker-compose ps
else
    echo "   未找到docker-compose.yml文件"
fi

# 检查端口占用
echo -e "\n🌐 端口状态检查:"
echo "   端口 80 (Nginx代理): $(netstat -an 2>/dev/null | grep ':80 ' | head -1 || echo '未占用')"
echo "   端口 8081 (后端服务): $(netstat -an 2>/dev/null | grep ':8081 ' | head -1 || echo '未占用')"
echo "   端口 8084 (AI推理): $(netstat -an 2>/dev/null | grep ':8084 ' | head -1 || echo '未占用')"
echo "   端口 8085 (.NET服务): $(netstat -an 2>/dev/null | grep ':8085 ' | head -1 || echo '未占用')"
echo "   端口 8086 (数据分析): $(netstat -an 2>/dev/null | grep ':8086 ' | head -1 || echo '未占用')"

echo -e "\n✨ 检查完成!"
