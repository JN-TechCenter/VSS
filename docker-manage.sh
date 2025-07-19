#!/bin/bash

echo "=== VSS Docker 管理脚本 ==="
echo ""

# 获取脚本目录
SCRIPT_DIR="$(dirname "$0")"
CONFIG_SCRIPT="$SCRIPT_DIR/config-manage.sh"

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

# 检查配置脚本是否存在
check_config_script() {
    if [ ! -f "$CONFIG_SCRIPT" ]; then
        log_error "配置管理脚本不存在: $CONFIG_SCRIPT"
        exit 1
    fi
    chmod +x "$CONFIG_SCRIPT"
}

# 加载环境配置
load_env_config() {
    local env=${1:-production}
    log_info "加载 $env 环境配置..."
    
    if ! bash "$CONFIG_SCRIPT" docker "$env"; then
        log_error "配置加载失败"
        exit 1
    fi
    
    # 验证配置
    if ! bash "$CONFIG_SCRIPT" validate "$env"; then
        log_error "配置验证失败"
        exit 1
    fi
    
    log_success "配置加载并验证成功"
}

# 函数定义
build_all() {
    local env=${1:-production}
    echo "🔨 构建所有服务 ($env 环境)..."
    
    load_env_config "$env"
    
    if [ "$env" = "development" ] || [ "$env" = "dev" ]; then
        docker-compose -f docker-compose.dev.yml --env-file .env.docker build --no-cache
    else
        docker-compose --env-file .env.docker build --no-cache
    fi
    
    if [ $? -eq 0 ]; then
        log_success "构建完成"
    else
        log_error "构建失败"
        exit 1
    fi
}

start_prod() {
    echo "🚀 启动生产环境..."
    
    load_env_config "production"
    
    # 加载环境变量
    if [ -f ".env.docker" ]; then
        source .env.docker
    fi
    
    docker-compose --env-file .env.docker up -d
    
    if [ $? -eq 0 ]; then
        log_success "生产环境已启动"
        echo "📱 前端访问: http://localhost:${FRONTEND_PORT:-3000}"
        echo "🔧 后端API: http://localhost:${BACKEND_PORT:-3002}"
        echo "📊 健康检查: http://localhost:${BACKEND_PORT:-3002}/actuator/health"
    else
        log_error "启动失败"
        exit 1
    fi
}

start_dev() {
    echo "🚀 启动开发环境..."
    
    load_env_config "development"
    
    # 加载环境变量
    if [ -f ".env.docker" ]; then
        source .env.docker
    fi
    
    docker-compose -f docker-compose.dev.yml --env-file .env.docker up -d
    
    if [ $? -eq 0 ]; then
        log_success "开发环境已启动"
        echo "📱 前端访问: http://localhost:${FRONTEND_PORT:-3001}"
        echo "🔧 后端API: http://localhost:${BACKEND_PORT:-3003}"
        echo "📧 邮件测试: http://localhost:8025 (MailHog)"
        echo "🗄️  数据库: localhost:${DB_PORT:-5433}"
    else
        log_error "启动失败"
        exit 1
    fi
}

stop_all() {
    echo "🛑 停止所有服务..."
    docker-compose down 2>/dev/null
    docker-compose -f docker-compose.dev.yml down 2>/dev/null
    log_success "所有服务已停止"
}

clean_all() {
    echo "🧹 清理 Docker 资源..."
    docker-compose down --volumes --remove-orphans
    docker-compose -f docker-compose.dev.yml down --volumes --remove-orphans
    docker system prune -f
    echo "✅ 清理完成"
}

logs() {
    echo "📋 查看日志..."
    docker-compose logs -f
}

status() {
    echo "📊 服务状态..."
    docker-compose ps
    docker-compose -f docker-compose.dev.yml ps
}

clean_all() {
    echo "🧹 清理 Docker 资源..."
    docker-compose down --volumes --remove-orphans 2>/dev/null
    docker-compose -f docker-compose.dev.yml down --volumes --remove-orphans 2>/dev/null
    
    # 清理未使用的镜像和容器
    docker system prune -f
    
    # 清理配置文件
    if [ -f ".env.docker" ]; then
        rm .env.docker
        log_info "已清理Docker配置文件"
    fi
    
    log_success "清理完成"
}

logs() {
    local service="$2"
    echo "📋 查看日志..."
    
    if [ -n "$service" ]; then
        log_info "查看服务 '$service' 的日志"
        docker-compose logs -f "$service" 2>/dev/null || \
        docker-compose -f docker-compose.dev.yml logs -f "$service" 2>/dev/null
    else
        log_info "查看所有服务日志"
        docker-compose logs -f 2>/dev/null || \
        docker-compose -f docker-compose.dev.yml logs -f 2>/dev/null
    fi
}

status() {
    echo "📊 服务状态..."
    echo ""
    echo "生产环境服务:"
    docker-compose ps
    echo ""
    echo "开发环境服务:"
    docker-compose -f docker-compose.dev.yml ps
    echo ""
    echo "Docker系统信息:"
    docker system df
}

restart() {
    local env=${2:-prod}
    echo "🔄 重启服务..."
    
    if [ "$env" = "dev" ] || [ "$env" = "development" ]; then
        log_info "重启开发环境"
        docker-compose -f docker-compose.dev.yml restart
    else
        log_info "重启生产环境"
        docker-compose restart
    fi
    
    log_success "服务已重启"
}

backup() {
    echo "💾 备份数据..."
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="./backups/$timestamp"
    
    mkdir -p "$backup_dir"
    
    # 备份数据库
    log_info "备份数据库..."
    docker-compose exec -T database pg_dump -U ${DB_USERNAME:-vss_user} ${DB_NAME:-vss_db} > "$backup_dir/database.sql" 2>/dev/null
    
    # 备份后端数据
    log_info "备份后端数据..."
    docker cp vss-backend:/app/data "$backup_dir/backend-data" 2>/dev/null
    
    # 备份配置文件
    log_info "备份配置文件..."
    cp .env* "$backup_dir/" 2>/dev/null
    
    log_success "备份完成: $backup_dir"
}

show_config() {
    local env=${2:-production}
    echo "⚙️  显示配置信息..."
    bash "$CONFIG_SCRIPT" show "$env"
}

health_check() {
    echo "🏥 健康检查..."
    
    # 检查容器状态
    local unhealthy=$(docker ps --filter "health=unhealthy" --format "table {{.Names}}\t{{.Status}}")
    if [ -n "$unhealthy" ]; then
        log_warning "发现不健康的容器:"
        echo "$unhealthy"
    else
        log_success "所有容器都正常运行"
    fi
    
    # 检查服务可访问性
    if [ -f ".env.docker" ]; then
        source .env.docker
        
        log_info "检查前端服务..."
        if curl -f -s "http://localhost:${FRONTEND_PORT:-3000}" > /dev/null; then
            log_success "前端服务正常"
        else
            log_error "前端服务不可访问"
        fi
        
        log_info "检查后端服务..."
        if curl -f -s "http://localhost:${BACKEND_PORT:-3002}/actuator/health" > /dev/null; then
            log_success "后端服务正常"
        else
            log_error "后端服务不可访问"
        fi
    fi
}

# 显示帮助信息
show_help() {
    echo "VSS Docker 管理脚本"
    echo ""
    echo "使用方法: $0 <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  build [env]    - 构建Docker镜像 (env: prod|dev, 默认prod)"
    echo "  start          - 启动生产环境"
    echo "  dev            - 启动开发环境"
    echo "  stop           - 停止所有服务"
    echo "  restart [env]  - 重启服务 (env: prod|dev, 默认prod)"
    echo "  clean          - 清理Docker资源"
    echo "  logs [service] - 查看服务日志"
    echo "  status         - 查看服务状态"
    echo "  backup         - 备份数据"
    echo "  config [env]   - 显示配置信息"
    echo "  health         - 健康检查"
    echo "  help           - 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build dev   # 构建开发环境镜像"
    echo "  $0 dev         # 启动开发环境"
    echo "  $0 logs backend # 查看后端日志"
    echo "  $0 config dev  # 显示开发环境配置"
}

# 主程序入口
main() {
    # 检查配置脚本
    check_config_script
    
    case "$1" in
        "build")
            build_all "$2"
            ;;
        "start")
            start_prod
            ;;
        "dev")
            start_dev
            ;;
        "stop")
            stop_all
            ;;
        "restart")
            restart "$@"
            ;;
        "clean")
            clean_all
            ;;
        "logs")
            logs "$@"
            ;;
        "status")
            status
            ;;
        "backup")
            backup
            ;;
        "config")
            show_config "$@"
            ;;
        "health")
            health_check
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
