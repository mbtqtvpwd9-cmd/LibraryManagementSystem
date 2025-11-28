#!/bin/bash

# 图书管理系统 - 快速部署脚本
# 针对Ubuntu服务器优化

set -e

echo "=== 图书管理系统快速部署 ==="
echo "🚀 技术栈：Vue 3 + Spring Boot 微服务"
echo ""

# 1. 安装必要环境
echo "步骤1: 安装必要环境..."

# 更新系统
sudo apt-get update

# 安装基础工具
sudo apt-get install -y curl wget git

# 安装Node.js和npm (使用NodeSource仓库)
echo "🟢 安装Node.js和npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装Java
echo "☕ 安装Java 17..."
sudo apt-get install -y openjdk-17-jdk

# 安装Maven
echo "🔨 安装Maven..."
sudo apt-get install -y maven

# 安装Docker
echo "🐳 安装Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

# 安装Docker Compose
echo "🔧 安装Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "✅ 环境安装完成！"
echo ""

# 2. 构建项目
echo "步骤2: 构建项目..."

# 构建前端
echo "📱 构建前端应用..."
cd frontend-vue
npm install
npm run build
cd ..

# 构建后端
echo "⚙️ 构建后端服务..."
cd backend-microservices
mvn clean package -DskipTests
cd ..

echo "✅ 项目构建完成！"
echo ""

# 3. 启动服务
echo "步骤3: 启动服务..."

# 停止并删除旧容器
echo "🧹 清理旧容器..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 创建网络
docker network create library-network 2>/dev/null || true

# 启动基础服务
echo "🗄️ 启动数据服务..."
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

# 等待基础服务启动
sleep 30

# 启动应用服务
echo "🚀 启动应用服务..."
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

# 启动前端
echo "📱 启动前端应用..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html \
  nginx:alpine

# 等待服务启动
sleep 30

echo ""
echo "✅ 部署完成！"
echo ""
echo "🌐 访问地址："
echo "   前端应用: http://150.158.125.55:3000/"
echo "   API网关: http://150.158.125.55:8080/"
echo ""
echo "🔧 管理命令："
echo "   查看服务状态: docker ps"
echo "   查看服务日志: docker logs <服务名>"
echo "   重启服务: docker restart <服务名>"
echo ""