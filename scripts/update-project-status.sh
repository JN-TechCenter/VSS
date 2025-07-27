#!/bin/bash
# VSS项目维护更新脚本
# 用于快速更新项目状态和工作计划

echo "🔄 VSS项目状态更新工具"
echo "========================"

# 获取当前时间
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M')

# 检查服务状态
echo "📊 检查服务状态..."

# 检查端口占用情况
check_port() {
    local port=$1
    local service=$2
    if netstat -an | grep ":$port " > /dev/null; then
        echo "✅ $service (端口 $port) - 运行中"
        return 0
    else
        echo "❌ $service (端口 $port) - 未运行"
        return 1
    fi
}

# 检查各个服务
echo ""
echo "🚦 服务状态检查:"
check_port 3001 "前端服务"
check_port 3002 "后端服务" 
check_port 8000 "AI推理服务"
check_port 80 "Nginx代理"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"

echo ""
echo "📝 更新选项:"
echo "1. 更新任务状态"
echo "2. 添加新任务"
echo "3. 更新服务状态"
echo "4. 生成状态报告"
echo "5. 退出"

read -p "请选择操作 (1-5): " choice

case $choice in
    1)
        echo "🔄 更新任务状态..."
        echo "请手动编辑 WORK_PLAN.md 文件中的任务状态"
        ;;
    2)
        echo "➕ 添加新任务..."
        echo "请手动编辑 WORK_PLAN.md 文件添加新任务"
        ;;
    3)
        echo "🔄 更新服务状态..."
        # 更新PROJECT_STATUS.md中的时间戳
        sed -i "s/最后检查.*$/最后检查 | $CURRENT_TIME |/" PROJECT_STATUS.md
        echo "✅ 服务状态已更新"
        ;;
    4)
        echo "📊 生成状态报告..."
        echo "=== VSS项目状态报告 ===" > status_report.txt
        echo "生成时间: $CURRENT_TIME" >> status_report.txt
        echo "" >> status_report.txt
        echo "服务状态:" >> status_report.txt
        check_port 3001 "前端服务" >> status_report.txt
        check_port 3002 "后端服务" >> status_report.txt
        check_port 8000 "AI推理服务" >> status_report.txt
        echo "✅ 状态报告已生成: status_report.txt"
        ;;
    5)
        echo "👋 退出更新工具"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac

echo ""
echo "💡 提示: 记得定期更新 WORK_PLAN.md 和 PROJECT_STATUS.md 文件"
echo "📝 工作计划文件: ./WORK_PLAN.md"
echo "📊 状态仪表板: ./PROJECT_STATUS.md"