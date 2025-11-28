#!/bin/bash

# 修复登录和Spring Security问题的脚本

echo "=== 开始修复登录和Spring Security问题 ==="

# 1. 停止现有容器
echo "1. 停止现有容器..."
docker stop library-backend library-frontend postgres redis 2>/dev/null || true
docker rm library-backend library-frontend postgres redis 2>/dev/null || true

# 2. 创建网络
echo "2. 创建Docker网络..."
docker network create library-network 2>/dev/null || true

# 3. 启动基础服务
echo "3. 启动PostgreSQL和Redis..."
docker run -d --name postgres \
  --network library-network \
  -e POSTGRES_DB=library \
  -e POSTGRES_USER=library \
  -e POSTGRES_PASSWORD=library123 \
  -p 5432:5432 \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  postgres:15

docker run -d --name redis \
  --network library-network \
  -p 6379:6379 \
  redis:7-alpine

# 4. 等待数据库启动
echo "4. 等待数据库启动..."
sleep 20

# 5. 检查数据库连接
echo "5. 检查数据库连接..."
docker exec postgres pg_isready -U library

# 6. 构建后端
echo "6. 构建后端JAR..."
mvn clean package -DskipTests

# 7. 构建前端
echo "7. 构建前端..."
cd frontend-vue
npm install
npm run build
cd ..

# 8. 创建前端构建目录
echo "8. 准备前端文件..."
mkdir -p frontend-build
cp -r frontend-vue/dist/* frontend-build/

# 9. 启动后端服务
echo "9. 启动后端服务..."
docker run -d --name library-backend \
  --network library-network \
  -p 3000:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  -e SPRING_REDIS_HOST=redis \
  -e SPRING_REDIS_PORT=6379 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 10. 启动前端服务
echo "10. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 8080:80 \
  -v $(pwd)/frontend-build:/usr/share/nginx/html:ro \
  nginx:alpine

# 11. 等待服务启动
echo "11. 等待服务启动..."
sleep 30

# 12. 检查服务状态
echo "12. 检查服务状态..."
echo "后端服务状态:"
curl -f http://localhost:3000/api/auth/me || echo "后端服务尚未完全启动，请稍等"

echo ""
echo "前端服务状态:"
curl -f http://localhost:8080 || echo "前端服务尚未完全启动，请稍等"

# 13. 检查登录API
echo ""
echo "13. 检查登录API..."
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123","role":"ADMIN"}' \
  || echo "登录API尚未完全启动，请稍等"

echo ""
echo "=== 修复完成 ==="
echo ""
echo "访问地址:"
echo "- 前端应用: http://localhost:8080"
echo "- 后端API: http://localhost:3000"
echo ""
echo "默认登录账户:"
echo "- 管理员: admin / admin123"
echo "- 读者: reader / reader123"
echo ""
echo "如果服务尚未完全启动，请等待1-2分钟后重试"