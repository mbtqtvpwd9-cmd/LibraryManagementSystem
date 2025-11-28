#!/bin/bash

echo "=== 修复Maven构建错误 ==="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 错误处理
handle_error() {
    echo -e "${RED}错误: $1${NC}"
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 检测当前目录
CURRENT_DIR=$(pwd)
PROJECT_ROOT="/Volumes/learn/AI/LibraryManagementSystem"

if [ "$CURRENT_DIR" != "$PROJECT_ROOT" ]; then
    warning "当前不在项目根目录，切换到项目根目录..."
    cd "$PROJECT_ROOT"
fi

echo ""
info "检测项目结构..."

# 检查是否有简化版项目
if [ -f "pom.xml" ] && grep -q "library-management-system" "pom.xml"; then
    success "发现简化版单体应用项目"
    echo ""
    info "解决方案1: 使用简化版单体应用（推荐）"
    echo "  简化版已经完整配置，可以直接运行："
    echo "  ./build-complete-project.sh"
    echo ""
    
    read -p "是否使用简化版构建? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "开始构建简化版单体应用..."
        
        # 清理Maven缓存中的错误依赖
        if [ -d "$HOME/.m2/repository/com/example/library/common-service" ]; then
            warning "清理Maven缓存中的错误依赖..."
            rm -rf "$HOME/.m2/repository/com/example/library/common-service"
        fi
        
        # 构建简化版
        if command -v mvn &> /dev/null; then
            info "使用Maven构建..."
            mvn clean compile -DskipTests
            if [ $? -eq 0 ]; then
                success "简化版构建成功！"
                info "运行命令: ./build-complete-project.sh"
            else
                handle_error "简化版构建失败"
            fi
        else
            warning "未找到Maven，使用简化运行脚本..."
            ./run-simple.sh
        fi
        exit 0
    fi
fi

echo ""
info "解决方案2: 修复微服务版本依赖问题"
echo ""

# 检查微服务项目
if [ -d "backend-microservices" ]; then
    success "发现微服务项目"
    
    info "步骤1: 清理Maven本地仓库中的错误依赖..."
    if [ -d "$HOME/.m2/repository/com/example/library" ]; then
        rm -rf "$HOME/.m2/repository/com/example/library"
        success "已清理Maven本地仓库"
    fi
    
    info "步骤2: 按正确顺序构建微服务模块..."
    
    cd backend-microservices
    
    # 检查common-service是否存在
    if [ ! -f "common-service/pom.xml" ]; then
        handle_error "common-service模块不存在，请先创建"
    fi
    
    # 构建common-service
    info "构建common-service..."
    cd common-service
    if command -v mvn &> /dev/null; then
        mvn clean install -DskipTests -U
        if [ $? -ne 0 ]; then
            handle_error "common-service构建失败"
        fi
        success "common-service构建成功"
    else
        handle_error "未找到Maven，无法构建微服务版本"
    fi
    cd ..
    
    # 检查其他服务
    SERVICES=("user-service" "book-service" "borrow-service" "gateway-service")
    
    for service in "${SERVICES[@]}"; do
        if [ -f "$service/pom.xml" ]; then
            info "构建 $service..."
            cd "$service"
            mvn clean install -DskipTests -U
            if [ $? -eq 0 ]; then
                success "$service 构建成功"
            else
                warning "$service 构建失败，继续..."
            fi
            cd ..
        else
            warning "$service 模块不存在，跳过..."
        fi
    done
    
    cd ..
    success "微服务构建完成！"
    
else
    handle_error "未找到有效的项目结构"
fi

echo ""
info "解决方案3: 强制更新Maven依赖"
echo "如果上述方法都不行，可以尝试："
echo "  mvn dependency:purge-local-repository"
echo "  mvn clean install -U"
echo ""

echo ""
success "问题解决建议："
echo "1. 推荐使用简化版单体应用（功能完整，依赖简单）"
echo "2. 如果必须使用微服务，请确保按顺序构建：common-service → other-services"
echo "3. 清理Maven缓存后重新构建"
echo ""

info "快速命令："
echo "  简化版: ./build-complete-project.sh"
echo "  微服务版: cd backend-microservices && mvn clean install -DskipTests -U"