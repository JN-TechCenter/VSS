#!/bin/bash

# VSS 快速启动脚本
# 一键启动开发或生产环境

echo "🚀 VSS 视觉平台快速启动"
echo "=========================="

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 选择环境
echo ""
echo "请选择环境:"
echo "1) 开发环境 (推荐用于日常开发)"
echo "2) 生产环境 (用于演示或部署)"
echo ""
read -p "请输入选择 (1-2): " choice

case $choice in
    1)
        echo ""
        echo "🛠️  启动开发环境..."
        echo "特性："
        echo "  ✓ 热重载"
        echo "  ✓ 详细日志"
        echo "  ✓ 开发工具"
        echo "  ✓ 测试数据库"
        echo ""
        
        # 构建并启动开发环境
        ./docker-manage.sh build dev
        ./docker-manage.sh dev
        
        echo ""
        echo "✅ 开发环境启动完成！"
        echo ""
        echo "🌐 访问地址："
        echo "   前端: http://localhost:3001"
        echo "   后端: http://localhost:3003"
        echo "   邮件测试: http://localhost:8025"
        echo ""
        echo "💡 开发提示："
        echo "   - 代码修改会自动重载"
        echo "   - 使用 ./docker-manage.sh logs 查看日志"
        echo "   - 使用 ./docker-manage.sh stop 停止服务"
        ;;
    2)
        echo ""
        echo "🏭 启动生产环境..."
        echo "特性："
        echo "  ✓ 性能优化"
        echo "  ✓ 安全配置"
        echo "  ✓ 监控告警"
        echo "  ✓ 自动重启"
        echo ""
        
        # 构建并启动生产环境
        ./docker-manage.sh build prod
        ./docker-manage.sh start
        
        echo ""
        echo "✅ 生产环境启动完成！"
        echo ""
        echo "🌐 访问地址："
        echo "   前端: http://localhost:3000"
        echo "   后端: http://localhost:3002"
        echo ""
        echo "🔧 管理命令："
        echo "   - 查看状态: ./docker-manage.sh status"
        echo "   - 健康检查: ./docker-manage.sh health"
        echo "   - 数据备份: ./docker-manage.sh backup"
        ;;
    *)
        echo "❌ 无效选择，退出"
        exit 1
        ;;
esac

echo ""
echo "🎉 启动完成！开始使用 VSS 视觉平台吧！"
