#!/bin/bash

# 图书管理系统 - 修复后端连接问题

set -e

echo "=== 修复后端连接问题 ==="
echo ""

# 1. 获取服务器IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "服务器IP: $EXTERNAL_IP"

# 2. 检查后端容器状态
echo ""
echo "1. 检查后端容器状态..."
BACKEND_RUNNING=$(docker ps --format "{{.Names}}\t{{.Status}}" | grep library-backend)
if [ -n "$BACKEND_RUNNING" ]; then
    echo "✅ 后端容器运行中:"
    echo "$BACKEND_RUNNING"
else
    echo "❌ 后端容器未运行"
fi

# 3. 检查后端日志
echo ""
echo "2. 检查后端日志..."
if docker ps --format "{{.Names}}" | grep -q library-backend; then
    echo "最后10行日志:"
    docker logs --tail 10 library-backend
else
    echo "❌ 后端容器不存在"
fi

# 4. 检查端口绑定
echo ""
echo "3. 检查端口绑定..."
netstat -tulpn | grep :8080 || echo "❌ 端口8080未绑定"

# 5. 检查JAR文件
echo ""
echo "4. 检查JAR文件..."
if [ -f "target/library-management-system.jar" ]; then
    echo "✅ JAR文件存在"
    ls -lh target/library-management-system.jar
else
    echo "❌ JAR文件不存在，正在构建..."
    mvn clean package -DskipTests
fi

# 6. 检查网络连接
echo ""
echo "5. 检查网络连接..."
docker network ls | grep library-network || echo "❌ library-network不存在"

# 7. 检查数据库连接
echo ""
echo "6. 检查数据库连接..."
if docker ps --format "{{.Names}}" | grep -q postgres; then
    echo "✅ PostgreSQL容器运行中"
    
    # 测试数据库连接
    PGPASSWORD="library123" psql -h localhost -p 5432 -U library -d library -c "SELECT 1;" 2>/dev/null && echo "✅ 数据库连接正常" || echo "❌ 数据库连接失败"
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

# 8. 重建后端容器（使用新的配置）
echo ""
echo "7. 重建后端容器..."
docker stop library-backend 2>/dev/null || echo "没有运行中的library-backend容器"
docker rm library-backend 2>/dev/null || echo "没有需要删除的library-backend容器"

# 创建一个临时配置文件
echo "创建临时应用配置..."
mkdir -p temp-config
cat > temp-config/application.properties << 'EOF'
server.port=8080
server.address=0.0.0.0

# 数据库配置
spring.datasource.url=jdbc:postgresql://postgres:5432/library
spring.datasource.username=library
spring.datasource.password=library123
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA配置
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# Redis配置
spring.redis.host=redis
spring.redis.port=6379

# 安全配置
spring.security.user.name=admin
spring.security.user.password=admin123
EOF

# 启动新的后端容器
echo "启动新的后端容器..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  -v $(pwd)/temp-config:/config \
  openjdk:17-jdk-slim \
  java -jar -Dspring.config.location=/config/application.properties /app.jar

# 9. 等待服务启动
echo ""
echo "8. 等待服务启动..."
echo "等待60秒让应用完全启动..."
sleep 60

# 10. 测试本地连接
echo ""
echo "9. 测试本地连接..."
for i in {1..5}; do
    LOCAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
    if [ "$LOCAL_STATUS" = "200" ]; then
        echo "✅ 本地连接成功 (状态码: $LOCAL_STATUS)"
        break
    else
        echo "⏳ 本地连接尝试 $i/5 (状态码: $LOCAL_STATUS)"
        if [ $i -lt 5 ]; then
            sleep 10
        fi
    fi
done

# 11. 测试API端点
echo ""
echo "10. 测试API端点..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/books 2>/dev/null || echo "000")
if [ "$API_STATUS" = "200" ] || [ "$API_STATUS" = "401" ]; then
    echo "✅ API端点响应正常 (状态码: $API_STATUS)"
else
    echo "❌ API端点无响应 (状态码: $API_STATUS)"
    
    # 再次检查日志
    echo ""
    echo "检查后端日志..."
    docker logs --tail 20 library-backend
fi

# 12. 测试外部连接
echo ""
echo "11. 测试外部连接..."
EXTERNAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP:8080 2>/dev/null || echo "000")
if [ "$EXTERNAL_STATUS" = "200" ]; then
    echo "✅ 外部连接成功 (状态码: $EXTERNAL_STATUS)"
    echo "🎉 后端服务已成功部署并可外部访问！"
    echo ""
    echo "📊 后端API: http://$EXTERNAL_IP:8080"
    echo "🌐 前端应用: http://$EXTERNAL_IP:3000"
else
    echo "❌ 外部连接失败 (状态码: $EXTERNAL_STATUS)"
    echo ""
    echo "可能的原因："
    echo "1. 防火墙未开放8080端口"
    echo "2. 腾讯云安全组未配置8080端口"
    echo ""
    echo "解决方案："
    echo "1. 检查并开放防火墙："
    echo "   sudo ufw status"
    echo "   sudo ufw allow 8080/tcp"
    echo ""
    echo "2. 在腾讯云控制台配置安全组："
    echo "   - 类型：自定义"
    echo "   - 来源：0.0.0.0/0"
    echo "   - 协议端口：TCP:8080"
    echo "   - 策略：允许"
fi

# 13. 清理临时文件
echo ""
echo "12. 清理临时文件..."
rm -rf temp-config

echo ""
echo "=== 修复完成 ==="