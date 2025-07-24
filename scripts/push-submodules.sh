#!/bin/bash

# =============================================================================
# VSS项目子模块推送脚本
# 功能: 自动化Git子模块的提交和推送到GitHub
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

# 推送单个子模块
push_single_submodule() {
    local submodule_path=$1
    log_info "📦 处理子模块: $submodule_path"
    
    # 检查子模块目录是否存在
    if [ ! -d "$submodule_path" ]; then
        log_warning "子模块目录 $submodule_path 不存在，跳过"
        return 0
    fi
    
    # 进入子模块目录
    pushd "$submodule_path" > /dev/null
    
    # 检查是否是Git仓库
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warning "目录 $submodule_path 不是Git仓库，跳过"
        popd > /dev/null
        return 0
    fi
    
    # 获取当前分支
    current_branch=$(git branch --show-current)
    
    # 检查是否有更改
    changes=$(git status --porcelain | wc -l)
    
    if [ "$changes" -eq 0 ]; then
        log_info "子模块 $submodule_path 没有需要提交的更改"
    else
        log_info "子模块 $submodule_path 有 $changes 个更改需要提交"
        
        # 添加所有更改
        git add .
        
        # 提交更改
        read -p "请输入提交信息 [自动提交更改]: " commit_message
        commit_message=${commit_message:-"自动提交更改"}
        
        git commit -m "$commit_message"
        if [ $? -ne 0 ]; then
            log_error "子模块 $submodule_path 提交失败"
            popd > /dev/null
            return 1
        fi
        
        log_success "子模块 $submodule_path 提交成功"
    fi
    
    # 推送到远程仓库
    log_info "推送子模块 $submodule_path 到远程仓库 (分支: $current_branch)..."
    
    git push origin $current_branch
    if [ $? -ne 0 ]; then
        log_error "子模块 $submodule_path 推送失败"
        popd > /dev/null
        return 1
    fi
    
    log_success "子模块 $submodule_path 推送成功"
    
    # 返回上级目录
    popd > /dev/null
    return 0
}

# 推送所有子模块
push_submodules() {
    log_info "🚀 开始推送所有子模块到GitHub..."
    
    # 检查Git仓库状态
    check_git_status || return 1
    
    # 获取所有子模块路径
    git config --file .gitmodules --get-regexp path | sed 's/submodule\.\(.*\)\.path \(.*\)/\2/' | while read submodule_path; do
        push_single_submodule "$submodule_path"
    done
    
    log_success "✅ 所有子模块推送完成"
}

# 显示帮助信息
show_help() {
    echo "VSS项目子模块推送脚本"
    echo ""
    echo "使用方法:"
    echo "  ./push-submodules.sh"
    echo ""
    echo "功能:"
    echo "  自动进入每个子模块目录，提交更改并推送到GitHub仓库"
    echo ""
}

# 主函数
main() {
    case "${1:-push}" in
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            push_submodules
            ;;
    esac
}

# 执行主函数
main "$@"