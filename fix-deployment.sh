#!/bin/bash

# 图书管理系统 - 部署修复脚本

set -e

echo "=== 图书管理系统部署修复 ==="
echo ""

# 1. 检查Docker是否运行
echo "1. 检查Docker状态..."
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker未运行，正在启动..."
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "✅ Docker正在运行"
fi

# 2. 停止并删除旧容器
echo ""
echo "2. 清理旧容器..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 3. 创建网络
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

# 6. 检查项目构建
echo ""
echo "6. 检查项目构建..."
if [ ! -f "backend-microservices/gateway-service/target/gateway-service.jar" ]; then
    echo "🔨 构建后端服务..."
    cd backend-microservices
    mvn clean package -DskipTests
    cd ..
fi

if [ ! -d "frontend-vue/dist" ]; then
    echo "📱 构建前端服务..."
    cd frontend-vue
    npm install
    npm run build
    cd ..
fi

# 7. 启动应用服务
echo ""
echo "7. 启动应用服务..."

# 启动网关服务
docker run -d --name library-gateway \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/backend-microservices/gateway-service/target/gateway-service.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar /app.jar

# 启动图书服务
docker run -d --name library-book-service \
  --network library-network \
  -p 8081:8081 \
  -v $(pwd)/backend-microservices/book-service/target/book-service.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar /app.jar

# 启动用户服务
docker run -d --name library-user-service \
  --network library-network \
  -p 8082:8082 \
  -v $(pwd)/backend-microservices/user-service/target/user-service.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar /app.jar

# 8. 启动前端
echo ""
echo "8. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 9. 等待服务启动
echo ""
echo "9. 等待服务启动..."
sleep 45

# 10. 检查服务状态
echo ""
echo "10. 检查服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 11. 测试服务访问
echo ""
echo "11. 测试服务访问..."
echo "前端应用 (3000端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:3000 || echo "❌ 前端服务不可访问"

echo "API网关 (8080端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8080 || echo "❌ 网关服务不可访问"

echo ""
echo "✅ 部署修复完成！"
echo ""
echo "🌐 访问地址："
echo "   前端应用: http://150.158.125.55:3000/"
echo "   API网关: http://150.158.125.55:8080/"
echo ""
echo "🔧 查看日志命令："
echo "   前端日志: docker logs library-frontend"
echo "   网关日志: docker logs library-gateway"
echo "   图书服务日志: docker logs library-book-service"
echo "   用户服务日志: docker logs library-user-service"
echo ""