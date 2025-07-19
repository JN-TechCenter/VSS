#!/bin/bash

# VSS 项目部署脚本
# 使用 Nginx 反向代理简化端口管理

echo "=== VSS 项目 Nginx 代理部署 ==="

# 检查配置文件
if [ ! -f ".env" ]; then
    echo "❌ 缺少 .env 配置文件"
    exit 1
fi

if [ ! -f "nginx.conf" ]; then
    echo "❌ 缺少 nginx.conf 配置文件"
    exit 1
fi

# 加载环境变量
source .env

echo "📋 当前配置："
echo "   - Nginx 主端口: ${NGINX_PORT:-80}"
echo "   - 开发工具端口: ${NGINX_DEV_TOOLS_PORT:-8080}"
echo "   - 管理工具端口: ${NGINX_ADMIN_PORT:-8081}"
echo "   - 网络名称: ${DOCKER_NETWORK:-vss-network}"

# 停止现有容器
echo "🛑 停止现有容器..."
docker-compose down

# 清理无用镜像
echo "🧹 清理无用镜像..."
docker image prune -f

# 构建并启动服务
echo "🚀 启动 VSS 平台服务..."
docker-compose up -d --build

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "📊 检查服务状态："
docker-compose ps

# 显示访问地址
echo ""
echo "✅ VSS 平台已启动！"
echo "🌐 访问地址："
echo "   - 主应用: http://localhost:${NGINX_PORT:-80}"
echo "   - 邮件测试: http://localhost:${NGINX_DEV_TOOLS_PORT:-8080}"
echo "   - 数据库管理: http://localhost:${NGINX_ADMIN_PORT:-8081}"
echo ""
echo "📝 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down"
