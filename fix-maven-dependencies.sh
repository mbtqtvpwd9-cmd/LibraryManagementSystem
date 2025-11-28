#!/bin/bash

# 完整项目构建脚本，解决Maven依赖问题

echo "=== 开始完整项目构建 ==="

# 1. 确定当前目录
PROJECT_ROOT=$(pwd)

# 2. 检查是否存在简化版项目（根目录pom.xml）
if [ -f "$PROJECT_ROOT/pom.xml" ] && grep -q "library-management-system" "$PROJECT_ROOT/pom.xml"; then
    echo "发现简化版单体应用项目，开始构建..."
    
    # 清理并安装
    cd "$PROJECT_ROOT"
    mvn clean install -DskipTests -U
    
    echo "简化版单体应用构建完成！"
    echo "可以运行: ./fix-login-and-security.sh 来部署"
    
    exit 0
fi

# 3. 检查是否存在微服务项目
if [ -d "$PROJECT_ROOT/backend-microservices" ]; then
    echo "发现微服务架构项目，开始构建..."
    
    cd "$PROJECT_ROOT/backend-microservices"
    
    # 按依赖顺序构建模块
    echo "1. 构建common-service..."
    cd common-service
    mvn clean install -DskipTests -U
    
    echo "2. 构建user-service..."
    cd ../user-service
    mvn clean install -DskipTests -U
    
    echo "3. 构建book-service..."
    cd ../book-service
    mvn clean install -DskipTests -U
    
    echo "4. 构建borrow-service..."
    cd ../borrow-service
    mvn clean install -DskipTests -U
    
    echo "5. 构建gateway-service..."
    cd ../gateway-service
    mvn clean install -DskipTests -U
    
    echo "微服务架构构建完成！"
    
    cd "$PROJECT_ROOT"
    echo "可以运行: ./fix-login-and-security.sh 来部署"
    
    exit 0
fi

# 4. 如果都没有找到
echo "错误: 未找到有效的项目结构!"
echo "请确保你在项目根目录或项目结构正确"

exit 1