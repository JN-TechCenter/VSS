#!/bin/bash

# =============================================================================
# VSS项目子模块管理脚本
# 功能: 自动化Git子模块的初始化、更新和管理
# 作者: VSS开发团队
# 版本: 1.0.0
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色配置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Git仓库状态
check_git_status() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是Git仓库"
        exit 1
    fi
    
    if [ ! -f ".gitmodules" ]; then
        log_warning "未找到.gitmodules文件"
        return 1
    fi
    
    return 0
}

# 初始化所有子模块
init_submodules() {
    log_info "🚀 初始化所有子模块..."
    
    git submodule update --init --recursive
    
    if [ $? -eq 0 ]; then
        log_success "✅ 所有子模块初始化完成"
        list_submodules
    else
        log_error "❌ 子模块初始化失败"
        exit 1
    fi
}

# 更新所有子模块
update_submodules() {
    log_info "🔄 更新所有子模块到最新版本..."
    
    # 获取更新前的子模块状态
    before_status=$(git submodule status)
    
    # 更新子模块
    git submodule update --remote --recursive
    
    # 获取更新后的状态
    after_status=$(git submodule status)
    
    # 检查是否有更新
    if [ "$before_status" != "$after_status" ]; then
        log_info "📦 检测到子模块更新，准备提交..."
        
        # 显示更新的子模块
        git diff --name-only HEAD -- $(git submodule status | awk '{print $2}')
        
        # 提交更新
        git add .
        git commit -m "Update: 自动更新所有子模块到最新版本

$(git submodule status)"
        
        log_success "✅ 子模块更新已提交"
    else
        log_success "✅ 所有子模块都是最新版本"
    fi
}

# 添加新的子模块
add_submodule() {
    local repo_url=$1
    local local_path=$2
    
    if [ -z "$repo_url" ] || [ -z "$local_path" ]; then
        log_error "使用方法: add_submodule <仓库URL> <本地路径>"
        exit 1
    fi
    
    log_info "➕ 添加新子模块: $repo_url -> $local_path"
    
    # 检查路径是否已存在
    if [ -d "$local_path" ]; then
        log_error "路径 $local_path 已存在"
        exit 1
    fi
    
    # 添加子模块
    git submodule add "$repo_url" "$local_path"
    
    if [ $? -eq 0 ]; then
        git add .gitmodules "$local_path"
        git commit -m "Add: 添加子模块 $local_path

Repository: $repo_url
Path: $local_path"
        
        log_success "✅ 子模块 $local_path 添加成功"
    else
        log_error "❌ 子模块添加失败"
        exit 1
    fi
}

# 删除子模块
remove_submodule() {
    local submodule_path=$1
    
    if [ -z "$submodule_path" ]; then
        log_error "使用方法: remove_submodule <子模块路径>"
        exit 1
    fi
    
    log_info "🗑️  删除子模块: $submodule_path"
    
    # 检查子模块是否存在
    if ! git submodule status | grep -q "$submodule_path"; then
        log_error "子模块 $submodule_path 不存在"
        exit 1
    fi
    
    # 删除子模块
    git submodule deinit -f "$submodule_path"
    git rm -f "$submodule_path"
    rm -rf ".git/modules/$submodule_path"
    
    git commit -m "Remove: 删除子模块 $submodule_path"
    
    log_success "✅ 子模块 $submodule_path 删除成功"
}

# 列出所有子模块
list_submodules() {
    log_info "📋 子模块列表:"
    echo ""
    
    if ! check_git_status; then
        log_warning "没有找到子模块配置"
        return
    fi
    
    # 表头
    printf "%-30s %-20s %-40s\n" "路径" "分支" "仓库URL"
    printf "%-30s %-20s %-40s\n" "----" "----" "--------"
    
    # 读取.gitmodules文件
    while IFS= read -r line; do
        if [[ $line =~ ^\[submodule ]]; then
            submodule_name=$(echo "$line" | sed 's/\[submodule "\(.*\)"\]/\1/')
        elif [[ $line =~ ^[[:space:]]*path ]]; then
            path=$(echo "$line" | sed 's/.*= *//')
        elif [[ $line =~ ^[[:space:]]*url ]]; then
            url=$(echo "$line" | sed 's/.*= *//')
        elif [[ $line =~ ^[[:space:]]*branch ]]; then
            branch=$(echo "$line" | sed 's/.*= *//')
        elif [[ -z $line && -n $path ]]; then
            # 空行表示一个子模块配置结束
            printf "%-30s %-20s %-40s\n" "$path" "${branch:-main}" "$url"
            path=""
            url=""
            branch=""
        fi
    done < .gitmodules
    
    # 处理最后一个子模块（如果文件末尾没有空行）
    if [[ -n $path ]]; then
        printf "%-30s %-20s %-40s\n" "$path" "${branch:-main}" "$url"
    fi
    
    echo ""
}

# 检查子模块状态
status_submodules() {
    log_info "📊 子模块状态检查:"
    echo ""
    
    git submodule status
    
    echo ""
    log_info "🔍 详细状态:"
    
    # 检查每个子模块的状态
    git submodule foreach --quiet '
        echo "📁 子模块: $name"
        echo "   路径: $sm_path"
        echo "   提交: $(git rev-parse HEAD)"
        echo "   分支: $(git branch --show-current)"
        echo "   状态: $(git status --porcelain | wc -l) 个未提交的更改"
        echo ""
    '
}

# 同步所有子模块
sync_submodules() {
    log_info "🔄 同步所有子模块..."
    
    git submodule sync --recursive
    
    log_success "✅ 子模块同步完成"
}

# 重置所有子模块
reset_submodules() {
    log_warning "⚠️  这将重置所有子模块，丢失未提交的更改！"
    read -p "确定要继续吗? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        log_info "🔄 重置所有子模块..."
        
        git submodule deinit --all -f
        git submodule update --init --recursive
        
        log_success "✅ 所有子模块已重置"
    else
        log_info "操作已取消"
    fi
}

# 显示帮助信息
show_help() {
    echo "VSS项目子模块管理脚本"
    echo ""
    echo "使用方法:"
    echo "  ./manage-submodules.sh <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  init                    初始化所有子模块"
    echo "  update                  更新所有子模块到最新版本"
    echo "  add <url> <path>        添加新的子模块"
    echo "  remove <path>           删除指定子模块"
    echo "  list                    列出所有子模块"
    echo "  status                  检查子模块状态"
    echo "  sync                    同步子模块URL配置"
    echo "  reset                   重置所有子模块（危险操作）"
    echo "  help                    显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./manage-submodules.sh init"
    echo "  ./manage-submodules.sh add https://github.com/user/repo.git ./path/to/submodule"
    echo "  ./manage-submodules.sh update"
}

# 主函数
main() {
    case "${1:-help}" in
        "init")
            init_submodules
            ;;
        "update")
            update_submodules
            ;;
        "add")
            add_submodule "$2" "$3"
            ;;
        "remove")
            remove_submodule "$2"
            ;;
        "list")
            list_submodules
            ;;
        "status")
            status_submodules
            ;;
        "sync")
            sync_submodules
            ;;
        "reset")
            reset_submodules
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
