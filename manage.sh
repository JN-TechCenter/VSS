#!/bin/bash

# VSS 项目管理脚本

set -e

echo "🚀 VSS 项目管理助手"
echo "==================="

# 函数：检查Git状态
check_git_status() {
    local dir=$1
    local name=$2
    
    echo "📁 检查 $name..."
    cd "$dir"
    
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  $name 有未提交的更改："
        git status --short
        echo ""
    else
        echo "✅ $name 工作目录干净"
    fi
    
    cd - > /dev/null
}

# 函数：更新Git仓库
update_repo() {
    local dir=$1
    local name=$2
    
    echo "🔄 更新 $name..."
    cd "$dir"
    
    git fetch
    
    local behind=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
    
    if [ "$behind" -gt 0 ]; then
        echo "📥 $name 落后 $behind 个提交，正在拉取..."
        git pull origin main
        echo "✅ $name 更新完成"
    else
        echo "✅ $name 已是最新版本"
    fi
    
    cd - > /dev/null
    echo ""
}

# 函数：显示状态
show_status() {
    echo "📊 项目状态"
    echo "----------"
    
    check_git_status "." "主项目"
    
    if [ -d "VSS-frontend" ]; then
        check_git_status "VSS-frontend" "前端项目"
    fi
    
    if [ -d "VSS-backend" ]; then
        check_git_status "VSS-backend" "后端项目"
    fi
}

# 函数：更新所有仓库
update_all() {
    echo "🔄 更新所有仓库"
    echo "---------------"
    
    update_repo "." "主项目"
    
    if [ -d "VSS-frontend" ]; then
        update_repo "VSS-frontend" "前端项目"
    fi
    
    if [ -d "VSS-backend" ]; then
        update_repo "VSS-backend" "后端项目"
    fi
}

# 函数：启动开发环境
start_dev() {
    echo "🛠️  启动开发环境"
    echo "---------------"
    
    # 检查并启动后端
    if [ -d "VSS-backend" ]; then
        echo "🌱 启动后端服务..."
        cd VSS-backend
        mvn spring-boot:run &
        BACKEND_PID=$!
        cd ..
        echo "✅ 后端服务启动中 (PID: $BACKEND_PID)"
    fi
    
    # 检查并启动前端
    if [ -d "VSS-frontend" ]; then
        echo "🎨 启动前端服务..."
        cd VSS-frontend
        npm run dev &
        FRONTEND_PID=$!
        cd ..
        echo "✅ 前端服务启动中 (PID: $FRONTEND_PID)"
    fi
    
    echo ""
    echo "🌐 服务地址："
    echo "   前端: http://localhost:3000"
    echo "   后端: http://localhost:3002"
    echo ""
    echo "按 Ctrl+C 停止所有服务"
    
    # 等待中断信号
    trap 'echo "正在停止服务..."; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit' INT
    wait
}

# 主菜单
case "${1:-menu}" in
    "status"|"s")
        show_status
        ;;
    "update"|"u")
        update_all
        ;;
    "dev"|"d")
        start_dev
        ;;
    "menu"|*)
        echo "使用方法："
        echo "  $0 status   (s) - 显示所有仓库状态"
        echo "  $0 update   (u) - 更新所有仓库"
        echo "  $0 dev      (d) - 启动开发环境"
        echo ""
        echo "示例："
        echo "  $0 s        # 检查状态"
        echo "  $0 u        # 更新项目"  
        echo "  $0 d        # 开始开发"
        ;;
esac
