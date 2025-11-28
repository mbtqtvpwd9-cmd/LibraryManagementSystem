#!/bin/bash

# 修复腾讯云部署问题脚本

echo "=== 修复腾讯云部署问题 ==="

# 1. 停止所有服务
echo "1. 停止现有服务..."
docker-compose -f docker-compose.tencent.yml down -v || true
docker stop $(docker ps -q) 2>/dev/null || true
docker system prune -f

# 2. 检查当前目录结构
echo "2. 检查项目结构..."
if [ -f "pom.xml" ]; then
    echo "找到 pom.xml，检查项目类型..."
    if grep -q "library-management-system" pom.xml; then
        echo "✓ 这是单体应用版本"
        PROJECT_TYPE="monolith"
    else
        echo "✗ 这是微服务版本"
        PROJECT_TYPE="microservices"
    fi
else
    echo "✗ 当前目录没有 pom.xml"
    exit 1
fi

# 3. 根据项目类型选择构建方式
if [ "$PROJECT_TYPE" = "monolith" ]; then
    echo "3. 构建单体应用..."
    mvn clean package -DskipTests -q
    
    echo "4. 启动服务..."
    docker-compose -f docker-compose.tencent.yml up -d
    
else
    echo "3. 微服务版本需要特殊处理..."
    echo "清理Maven缓存..."
    mvn dependency:purge-local-repository -DmanualInclude="com.example.library:common-service"
    
    echo "尝试构建单体应用版本..."
    # 检查是否有单体应用版本
    if [ -f "../pom.xml" ] && [ -d "../src" ]; then
        echo "在上级目录找到单体应用版本"
        cd ..
        mvn clean package -DskipTests -q
        cd -
        cp ../target/library-management-system-1.0.0.jar ./target/ 2>/dev/null || mkdir -p target && cp ../target/library-management-system-1.0.0.jar ./target/
    else
        echo "✗ 找不到单体应用版本，请检查项目结构"
        exit 1
    fi
fi

# 5. 等待启动
echo "5. 等待服务启动..."
sleep 45

# 6. 检查状态
echo "6. 检查服务状态..."
docker-compose -f docker-compose.tencent.yml ps

# 7. 健康检查
echo "7. 健康检查..."
if curl -f http://localhost:8080/api/users/login &> /dev/null; then
    echo "✓ 应用启动成功"
else
    echo "⚠ 应用可能还在启动中，请稍后检查"
    echo "查看日志: docker-compose -f docker-compose.tencent.yml logs app"
fi

echo ""
echo "=== 部署完成 ==="
echo "访问地址: http://localhost:8080"
echo "管理员账户: admin/admin123"