#!/bin/bash

# 腾讯云部署脚本
# 使用方法: ./deploy.sh <github-repo-url>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    log_error "请提供GitHub仓库URL"
    echo "使用方法: ./deploy.sh <github-repo-url>"
    exit 1
fi

REPO_URL=$1
PROJECT_DIR="library-management-system"

log_info "开始部署图书管理系统到腾讯云..."

# 检查系统环境
log_info "检查系统环境..."
if ! command -v docker &> /dev/null; then
    log_error "Docker未安装，请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

if ! command -v git &> /dev/null; then
    log_error "Git未安装，请先安装Git"
    exit 1
fi

# 停止现有容器
log_info "停止现有容器..."
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    docker-compose down || true
    cd ..
fi

# 克隆或更新代码
if [ -d "$PROJECT_DIR" ]; then
    log_info "更新代码..."
    cd "$PROJECT_DIR"
    git pull origin main || git pull origin master
else
    log_info "克隆代码..."
    git clone "$REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# 构建并启动服务
log_info "构建Docker镜像..."
docker-compose build

log_info "启动服务..."
docker-compose up -d

# 等待服务启动
log_info "等待服务启动..."
sleep 30

# 检查服务状态
log_info "检查服务状态..."
docker-compose ps

# 检查应用健康状态
log_info "检查应用健康状态..."
for i in {1..10}; do
    if curl -f http://localhost:8080/api/books/count &> /dev/null; then
        log_info "应用启动成功！"
        break
    else
        if [ $i -eq 10 ]; then
            log_error "应用启动失败，请检查日志"
            docker-compose logs app
            exit 1
        fi
        log_warn "等待应用启动... ($i/10)"
        sleep 10
    fi
done

# 显示访问信息
log_info "部署完成！"
echo "==================================="
echo "应用访问地址: http://$(curl -s ifconfig.me):8080"
echo "本地访问地址: http://localhost:8080"
echo "默认管理员账户: admin/admin123"
echo "默认读者账户: reader/reader123"
echo "==================================="

# 显示有用的命令
echo ""
log_info "常用命令:"
echo "查看日志: docker-compose logs -f app"
echo "重启服务: docker-compose restart"
echo "停止服务: docker-compose down"
echo "查看状态: docker-compose ps"

log_info "部署脚本执行完成！"