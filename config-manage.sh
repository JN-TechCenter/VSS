#!/bin/bash

# VSS 配置管理脚本
# ==========================================

CONFIG_DIR="$(dirname "$0")"
ENV_FILE="$CONFIG_DIR/.env"
DEV_ENV_FILE="$CONFIG_DIR/.env.development"
PROD_ENV_FILE="$CONFIG_DIR/.env.production"

# 颜色定义
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

# 加载配置文件
load_config() {
    local env=${1:-development}
    
    log_info "加载 $env 环境配置..."
    
    # 首先加载基础配置
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
        log_success "基础配置已加载"
    else
        log_error "基础配置文件 .env 不存在"
        exit 1
    fi
    
    # 然后加载环境特定配置
    case "$env" in
        "development"|"dev")
            if [ -f "$DEV_ENV_FILE" ]; then
                set -a
                source "$DEV_ENV_FILE"
                set +a
                log_success "开发环境配置已加载"
            else
                log_warning "开发环境配置文件不存在，使用默认配置"
            fi
            ;;
        "production"|"prod")
            if [ -f "$PROD_ENV_FILE" ]; then
                set -a
                source "$PROD_ENV_FILE"
                set +a
                log_success "生产环境配置已加载"
            else
                log_warning "生产环境配置文件不存在，使用默认配置"
            fi
            ;;
        *)
            log_error "未知环境: $env"
            exit 1
            ;;
    esac
}

# 显示当前配置
show_config() {
    echo ""
    echo "===========================================" 
    echo "当前配置信息"
    echo "==========================================="
    echo "应用名称: $APP_NAME"
    echo "版本: $APP_VERSION"
    echo "环境: $NODE_ENV"
    echo ""
    echo "端口配置:"
    echo "  前端端口: $FRONTEND_PORT"
    echo "  后端端口: $BACKEND_PORT"
    echo "  Nginx端口: $NGINX_PORT"
    echo ""
    echo "API配置:"
    echo "  API基础URL: $API_BASE_URL"
    echo "  前端API URL: $VITE_API_BASE_URL"
    echo ""
    echo "数据库配置:"
    echo "  类型: $DB_TYPE"
    echo "  主机: $DB_HOST"
    echo "  端口: $DB_PORT"
    echo "  数据库名: $DB_NAME"
    echo "  用户名: $DB_USERNAME"
    echo ""
    echo "Docker配置:"
    echo "  镜像标签: $DOCKER_IMAGE_TAG"
    echo "  网络: $DOCKER_NETWORK"
    echo ""
    echo "安全配置:"
    echo "  CORS源: $CORS_ORIGIN"
    echo "  JWT密钥: [HIDDEN]"
    echo ""
    echo "==========================================="
}

# 验证配置
validate_config() {
    log_info "验证配置..."
    
    local errors=0
    
    # 检查必需的变量
    if [ -z "$APP_NAME" ]; then
        log_error "APP_NAME 未设置"
        ((errors++))
    fi
    
    if [ -z "$FRONTEND_PORT" ]; then
        log_error "FRONTEND_PORT 未设置"
        ((errors++))
    fi
    
    if [ -z "$BACKEND_PORT" ]; then
        log_error "BACKEND_PORT 未设置"
        ((errors++))
    fi
    
    if [ -z "$API_BASE_URL" ]; then
        log_error "API_BASE_URL 未设置"
        ((errors++))
    fi
    
    # 检查端口是否为数字
    if ! [[ "$FRONTEND_PORT" =~ ^[0-9]+$ ]]; then
        log_error "FRONTEND_PORT 必须是数字"
        ((errors++))
    fi
    
    if ! [[ "$BACKEND_PORT" =~ ^[0-9]+$ ]]; then
        log_error "BACKEND_PORT 必须是数字"
        ((errors++))
    fi
    
    # 检查端口范围
    if [ "$FRONTEND_PORT" -lt 1024 ] || [ "$FRONTEND_PORT" -gt 65535 ]; then
        log_warning "FRONTEND_PORT 建议使用 1024-65535 范围"
    fi
    
    if [ "$BACKEND_PORT" -lt 1024 ] || [ "$BACKEND_PORT" -gt 65535 ]; then
        log_warning "BACKEND_PORT 建议使用 1024-65535 范围"
    fi
    
    # 检查生产环境安全配置
    if [ "$NODE_ENV" = "production" ]; then
        if [ "$JWT_SECRET" = "dev-jwt-secret-key" ]; then
            log_error "生产环境不能使用默认的JWT密钥"
            ((errors++))
        fi
        
        if [ "$SESSION_SECRET" = "dev-session-secret" ]; then
            log_error "生产环境不能使用默认的Session密钥"
            ((errors++))
        fi
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "配置验证通过"
        return 0
    else
        log_error "配置验证失败，发现 $errors 个错误"
        return 1
    fi
}

# 生成Docker环境文件
generate_docker_env() {
    local env=${1:-development}
    local output_file="$CONFIG_DIR/.env.docker"
    
    log_info "生成Docker环境文件..."
    
    # 加载配置
    load_config "$env"
    
    # 生成Docker专用的环境文件
    cat > "$output_file" << EOF
# Docker环境配置文件 (自动生成，请勿手动编辑)
# 生成时间: $(date)
# 环境: $env

# 应用配置
APP_NAME=$APP_NAME
APP_VERSION=$APP_VERSION
NODE_ENV=$NODE_ENV

# 端口配置
FRONTEND_PORT=$FRONTEND_PORT
BACKEND_PORT=$BACKEND_PORT
NGINX_PORT=$NGINX_PORT

# API配置
API_BASE_URL=$API_BASE_URL
VITE_API_BASE_URL=$VITE_API_BASE_URL

# 数据库配置
DB_TYPE=$DB_TYPE
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD

# Docker配置
DOCKER_IMAGE_TAG=$DOCKER_IMAGE_TAG
DOCKER_NETWORK=$DOCKER_NETWORK

# 安全配置
JWT_SECRET=$JWT_SECRET
SESSION_SECRET=$SESSION_SECRET
CORS_ORIGIN=$CORS_ORIGIN

# 功能开关
DEV_HOT_RELOAD=$DEV_HOT_RELOAD
PROD_OPTIMIZE=$PROD_OPTIMIZE
LOG_LEVEL=$LOG_LEVEL
EOF
    
    log_success "Docker环境文件已生成: $output_file"
}

# 帮助信息
show_help() {
    echo "VSS 配置管理脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  load <env>     - 加载指定环境的配置"
    echo "  show [env]     - 显示当前或指定环境的配置"
    echo "  validate [env] - 验证配置"
    echo "  docker [env]   - 生成Docker环境文件"
    echo "  help          - 显示帮助信息"
    echo ""
    echo "环境参数:"
    echo "  development, dev  - 开发环境"
    echo "  production, prod  - 生产环境"
    echo ""
    echo "示例:"
    echo "  $0 load development"
    echo "  $0 show prod"
    echo "  $0 docker dev"
}

# 主程序
main() {
    case "$1" in
        "load")
            load_config "$2"
            ;;
        "show")
            if [ -n "$2" ]; then
                load_config "$2"
            fi
            show_config
            ;;
        "validate")
            load_config "$2"
            validate_config
            ;;
        "docker")
            generate_docker_env "$2"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
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

# 运行主程序
main "$@"
