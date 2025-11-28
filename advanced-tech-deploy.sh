#!/bin/bash

# 图书管理系统 - 先进技术栈部署脚本
# 使用Vue3 + Spring Cloud微服务架构

set -e

echo "=== 图书管理系统先进技术栈部署 ==="
echo "🚀 技术栈特点："
echo "   ✨ Vue 3 + TypeScript 现代化前端"
echo "   ⚙️ Spring Cloud 微服务架构后端"
echo "   🐳 容器化部署 + Kubernetes准备"
echo "   📊 PostgreSQL + Redis + MinIO 数据存储"
echo "   🔄 CI/CD 自动化部署流程"
echo ""

# 检查并安装必要环境
echo "🔧 检查和安装必要环境..."

# 检查并安装Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 安装Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
else
    echo "✅ Docker 已安装"
fi

# 检查并安装Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🔧 安装Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "✅ Docker Compose 已安装"
fi

# 检查并安装Node.js和npm
if ! command -v node &> /dev/null; then
    echo "🟢 安装Node.js和npm..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js 已安装"
fi

# 检查并安装Java 17
if ! command -v java &> /dev/null; then
    echo "☕ 安装Java 17..."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
else
    echo "✅ Java 已安装"
fi

# 检查并安装Maven
if ! command -v mvn &> /dev/null; then
    echo "🔨 安装Maven..."
    sudo apt-get install -y maven
else
    echo "✅ Maven 已安装"
fi

echo ""

# 1. 构建前端
echo "步骤1: 构建现代化前端..."
cd frontend-vue
npm install
npm run build
cd ..

# 2. 构建后端微服务
echo "步骤2: 构建后端微服务..."
cd backend-microservices

# 构建公共模块
echo "构建公共模块..."
cd common-service
mvn clean install -DskipTests
cd ..

# 构建API网关
echo "构建API网关..."
cd gateway-service
mvn clean package -DskipTests
cd ..

# 构建图书服务
echo "构建图书服务..."
cd book-service
mvn clean package -DskipTests
cd ..

# 构建用户服务
echo "构建用户服务..."
cd user-service
mvn clean package -DskipTests
cd ..

# 构建借阅服务
echo "构建借阅服务..."
cd borrow-service
mvn clean package -DskipTests
cd ..

cd ..

# 3. 构建Docker镜像
echo "步骤3: 构建Docker镜像..."
docker build -t library-gateway:latest ./backend-microservices/gateway-service
docker build -t library-book-service:latest ./backend-microservices/book-service
docker build -t library-user-service:latest ./backend-microservices/user-service
docker build -t library-borrow-service:latest ./backend-microservices/borrow-service
docker build -t library-frontend:latest ./frontend-vue

# 4. 创建Docker网络
echo "步骤4: 创建Docker网络..."
docker network create library-network 2>/dev/null || echo "网络已存在"

# 5. 启动基础服务
echo "步骤5: 启动基础服务..."
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

docker run -d --name minio \
  --network library-network \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  -p 9000:9000 \
  -p 9001:9001 \
  minio/minio:latest server /data --console-address ":9001"

docker run -d --name nacos \
  --network library-network \
  -e MODE=standalone \
  -p 8848:8848 \
  -p 9848:9848 \
  nacos/nacos-server:v2.2.3

# 6. 等待基础服务启动
echo "步骤6: 等待基础服务启动..."
sleep 60

# 7. 启动应用服务
echo "步骤7: 启动应用服务..."
docker run -d --name library-gateway \
  --network library-network \
  -e NACOS_SERVER_ADDR=nacos:8848 \
  -p 8080:8080 \
  library-gateway:latest

docker run -d --name library-book-service \
  --network library-network \
  -e NACOS_SERVER_ADDR=nacos:8848 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  -e SPRING_REDIS_HOST=redis \
  -e MINIO_ENDPOINT=http://minio:9000 \
  -e MINIO_ACCESS_KEY=minioadmin \
  -e MINIO_SECRET_KEY=minioadmin \
  library-book-service:latest

docker run -d --name library-user-service \
  --network library-network \
  -e NACOS_SERVER_ADDR=nacos:8848 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  -e SPRING_REDIS_HOST=redis \
  library-user-service:latest

docker run -d --name library-borrow-service \
  --network library-network \
  -e NACOS_SERVER_ADDR=nacos:8848 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  -e SPRING_REDIS_HOST=redis \
  library-borrow-service:latest

# 8. 等待应用服务启动
echo "步骤8: 等待应用服务启动..."
sleep 90

# 9. 检查服务状态
echo "步骤9: 检查服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 10. 显示服务日志
echo "步骤10: 显示服务日志..."
echo "=== 网关服务日志 ==="
docker logs --tail 20 library-gateway

echo ""
echo "=== 图书服务日志 ==="
docker logs --tail 20 library-book-service

echo ""
echo "=== 访问地址 ==="
echo "🌟 应用地址："
echo "   📱 前端应用: http://150.158.125.55:3000/"
echo "   🌐 API网关: http://150.158.125.55:8080/"
echo "   📊 Nacos控制台: http://150.158.125.55:8848/nacos/"
echo "   🗃️️ PostgreSQL: localhost:5432"
echo "   🔴 Redis: localhost:6379"
echo "   🪣 MinIO控制台: http://150.158.125.55:9001/"
echo ""
echo "✨ 技术栈优势："
echo "   ✅ 现代化前端架构，组件化开发"
echo "   ✅ 微服务后端架构，高可扩展性"
echo "   ✅ 混合数据访问策略，性能优化"
echo "   ✅ 完整的DevOps流程，持续交付"
echo "   ✅ 云原生部署，支持Kubernetes"
echo ""
echo "🔧 管理命令："
echo "   重启所有服务: ./advanced-tech-deploy.sh"
echo "   查看所有服务: docker ps --format 'table {{.Names}}\t{{.Status}}'"
echo "   查看服务日志: docker logs <service-name>"
echo "   停止所有服务: docker stop $(docker ps -q) && docker rm $(docker ps -aq)"
echo ""