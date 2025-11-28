#!/bin/bash

# 图书管理系统 - 手动部署脚本（修复版）

set -e

echo "=== 图书管理系统手动部署（修复版） ==="
echo ""

# 1. 拉取最新代码
echo "1. 拉取最新代码..."
git pull origin advanced-tech-stack

# 2. 停止并删除旧容器
echo ""
echo "2. 停止并删除旧容器..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 3. 创建Docker网络
echo ""
echo "3. 创建Docker网络..."
docker network create library-network 2>/dev/null || echo "网络已存在"

# 4. 启动基础服务
echo ""
echo "4. 启动基础服务..."
docker run -d --name postgres \
  --network library-network \
  -e POSTGRES_DB=library \
  -e POSTGRES_USER=library \
  -e POSTGRES_PASSWORD=library123 \
  -p 5432:5432 \
  postgres:15

docker run -d --name redis \
  --network library-network \
  -p 6379:6379 \
  redis:7-alpine

# 5. 等待基础服务启动
echo ""
echo "5. 等待基础服务启动..."
sleep 30

# 6. 检查项目结构并构建
echo ""
echo "6. 检查项目结构..."

# 检查微服务目录结构
if [ ! -f "backend-microservices/pom.xml" ]; then
    echo "❌ 未找到backend-microservices/pom.xml"
    echo "使用根目录的Spring Boot单体应用..."
    
    # 构建根目录的应用
    echo "🔨 构建Spring Boot应用..."
    mvn clean package -DskipTests
    
    # 启动单体应用
    echo ""
    echo "7. 启动Spring Boot单体应用..."
    docker run -d --name library-backend \
      --network library-network \
      -p 8080:8080 \
      -v $(pwd)/target/library-management-system.jar:/app.jar \
      openjdk:17-jdk-slim \
      java -jar /app.jar
else
    # 构建微服务
    echo "🔨 构建微服务..."
    cd backend-microservices
    
    # 构建公共模块
    echo "构建公共模块..."
    cd common-service
    mvn clean install -DskipTests
    cd ..
    
    # 构建各个服务
    echo "构建API网关..."
    cd gateway-service
    mvn clean package -DskipTests
    cd ..
    
    echo "构建图书服务..."
    cd book-service
    mvn clean package -DskipTests
    cd ..
    
    echo "构建用户服务..."
    cd user-service
    mvn clean package -DskipTests
    cd ..
    
    echo "构建借阅服务..."
    cd borrow-service
    mvn clean package -DskipTests
    cd ..
    
    cd ..
    
    # 启动微服务
    echo ""
    echo "7. 启动微服务..."
    docker run -d --name library-gateway \
      --network library-network \
      -p 8080:8080 \
      -v $(pwd)/backend-microservices/gateway-service/target/gateway-service.jar:/app.jar \
      openjdk:17-jdk-slim \
      java -jar /app.jar
    
    docker run -d --name library-book-service \
      --network library-network \
      -p 8081:8081 \
      -v $(pwd)/backend-microservices/book-service/target/book-service.jar:/app.jar \
      openjdk:17-jdk-slim \
      java -jar /app.jar
    
    docker run -d --name library-user-service \
      --network library-network \
      -p 8082:8082 \
      -v $(pwd)/backend-microservices/user-service/target/user-service.jar:/app.jar \
      openjdk:17-jdk-slim \
      java -jar /app.jar
fi

# 8. 构建前端
echo ""
echo "8. 构建前端应用..."
cd frontend-vue
npm install
npm run build
cd ..

# 9. 启动前端服务
echo ""
echo "9. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 10. 等待服务启动
echo ""
echo "10. 等待服务启动..."
sleep 45

# 11. 检查服务状态
echo ""
echo "11. 检查服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 12. 测试服务访问
echo ""
echo "12. 测试服务访问..."
echo "前端应用 (3000端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:3000 || echo "❌ 前端服务不可访问"

echo "后端服务 (8080端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8080 || echo "❌ 后端服务不可访问"

echo ""
echo "✅ 部署完成！"
echo ""
echo "🌐 访问地址："
echo "   前端应用: http://150.158.125.55:3000/"
echo "   后端API: http://150.158.125.55:8080/"
echo ""
echo "🔧 查看日志命令："
echo "   前端日志: docker logs library-frontend"
echo "   后端日志: docker logs library-backend"