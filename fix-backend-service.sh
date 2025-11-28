#!/bin/bash

# 图书管理系统 - 修复后端服务

set -e

echo "=== 修复后端服务 ==="
echo ""

# 1. 检查后端容器状态
echo "1. 检查后端容器状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep library || echo "❌ 没有找到library相关容器"

# 2. 检查JAR文件
echo ""
echo "2. 检查JAR文件..."
if [ -f "target/library-management-system.jar" ]; then
    echo "✅ JAR文件存在"
    ls -lh target/library-management-system.jar
else
    echo "❌ JAR文件不存在，正在构建..."
    
    # 确保Java 17已安装
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 17 ]; then
        echo "安装Java 17..."
        sudo apt-get update
        sudo apt-get install -y openjdk-17-jdk
        sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
        sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    fi
    
    # 构建项目
    mvn clean package -DskipTests
fi

# 3. 检查数据库服务
echo ""
echo "3. 检查数据库服务..."
POSTGRES_STATUS=$(docker ps --format "{{.Names}}\t{{.Status}}" | grep postgres | awk '{print $2}' | cut -d'(' -f1)
if [ -n "$POSTGRES_STATUS" ]; then
    echo "✅ PostgreSQL容器运行状态: $POSTGRES_STATUS"
else
    echo "❌ PostgreSQL容器未运行，正在启动..."
    docker run -d --name postgres \
      --network library-network \
      -e POSTGRES_DB=library \
      -e POSTGRES_USER=library \
      -e POSTGRES_PASSWORD=library123 \
      -p 5432:5432 \
      postgres:15
    
    echo "等待PostgreSQL启动..."
    sleep 15
fi

# 4. 检查Redis服务
echo ""
echo "4. 检查Redis服务..."
REDIS_STATUS=$(docker ps --format "{{.Names}}\t{{.Status}}" | grep redis | awk '{print $2}' | cut -d'(' -f1)
if [ -n "$REDIS_STATUS" ]; then
    echo "✅ Redis容器运行状态: $REDIS_STATUS"
else
    echo "❌ Redis容器未运行，正在启动..."
    docker run -d --name redis \
      --network library-network \
      -p 6379:6379 \
      redis:7-alpine
    
    echo "等待Redis启动..."
    sleep 5
fi

# 5. 创建Docker网络（如果不存在）
echo ""
echo "5. 检查Docker网络..."
docker network ls | grep library-network || docker network create library-network

# 6. 停止旧的后端容器
echo ""
echo "6. 停止旧的后端容器..."
docker stop library-backend 2>/dev/null || echo "没有运行中的library-backend容器"
docker rm library-backend 2>/dev/null || echo "没有需要删除的library-backend容器"

# 7. 启动新的后端容器
echo ""
echo "7. 启动新的后端容器..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  -e SPRING_REDIS_HOST=redis \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 8. 等待后端服务启动
echo ""
echo "8. 等待后端服务启动..."
sleep 30

# 9. 测试本地访问
echo ""
echo "9. 测试本地访问..."
LOCAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$LOCAL_STATUS" = "200" ]; then
    echo "✅ 本地访问正常 (状态码: $LOCAL_STATUS)"
else
    echo "❌ 本地访问异常 (状态码: $LOCAL_STATUS)"
    
    # 检查容器日志
    echo ""
    echo "检查容器日志..."
    docker logs --tail 20 library-backend
fi

# 10. 测试API端点
echo ""
echo "10. 测试API端点..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/auth/health 2>/dev/null || echo "000")
if [ "$API_STATUS" = "200" ]; then
    echo "✅ API端点正常 (状态码: $API_STATUS)"
else
    echo "❌ API端点异常 (状态码: $API_STATUS)"
fi

# 11. 获取服务器IP并测试外部访问
echo ""
echo "11. 测试外部访问..."
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
EXTERNAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP:8080 2>/dev/null || echo "000")
if [ "$EXTERNAL_STATUS" = "200" ]; then
    echo "✅ 外部访问正常 (状态码: $EXTERNAL_STATUS)"
else
    echo "❌ 外部访问异常 (状态码: $EXTERNAL_STATUS)"
    echo "请检查防火墙设置："
    echo "   sudo ufw status"
    echo "   sudo ufw allow 8080/tcp"
fi

echo ""
echo "=== 修复完成 ==="
echo ""
echo "如果后端服务仍然不可用，请检查以下内容："
echo ""
echo "1. 查看容器日志："
echo "   docker logs library-backend"
echo ""
echo "2. 进入容器检查："
echo "   docker exec -it library-backend /bin/bash"
echo "   ps aux"
echo ""
echo "3. 检查网络连接："
echo "   docker exec library-backend ping postgres"
echo "   docker exec library-backend ping redis"