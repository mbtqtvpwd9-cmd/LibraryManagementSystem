#!/bin/bash

# 图书管理系统 - 部署状态检查脚本

echo "=== 图书管理系统部署状态检查 ==="
echo ""

# 1. 检查Docker容器状态
echo "1. 🐳 Docker容器状态："
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep library
echo ""

# 2. 检查服务端口是否可访问
echo "2. 🌐 服务端口状态："
echo "前端应用 (3000端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:3000 || echo "❌ 前端服务不可访问"

echo "API网关 (8080端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8080 || echo "❌ 网关服务不可访问"

echo "图书服务 (8081端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8081 || echo "❌ 图书服务不可访问"

echo "用户服务 (8082端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8082 || echo "❌ 用户服务不可访问"
echo ""

# 3. 检查服务日志
echo "3. 📋 服务日志（最新5行）："
echo "--- 前端日志 ---"
docker logs --tail 5 library-frontend 2>/dev/null || echo "❌ 前端容器不存在"

echo "--- 网关日志 ---"
docker logs --tail 5 library-gateway 2>/dev/null || echo "❌ 网关容器不存在"

echo "--- 图书服务日志 ---"
docker logs --tail 5 library-book-service 2>/dev/null || echo "❌ 图书服务容器不存在"

echo "--- 用户服务日志 ---"
docker logs --tail 5 library-user-service 2>/dev/null || echo "❌ 用户服务容器不存在"
echo ""

# 4. 检查外部IP访问
echo "4. 🌍 外部访问测试："
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "服务器IP: $EXTERNAL_IP"

echo "前端应用 (http://$EXTERNAL_IP:3000):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://$EXTERNAL_IP:3000 || echo "❌ 外部无法访问前端应用"

echo "API网关 (http://$EXTERNAL_IP:8080):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://$EXTERNAL_IP:8080 || echo "❌ 外部无法访问API网关"
echo ""

# 5. API功能测试
echo "5. 🧪 API功能测试："
echo "测试API健康检查..."
GATEWAY_URL="http://localhost:8080"
API_RESPONSE=$(curl -s "$GATEWAY_URL/actuator/health" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ API网关响应正常: $API_RESPONSE"
else
    echo "❌ API网关无响应"
fi

echo "测试图书服务API..."
BOOK_API_RESPONSE=$(curl -s "http://localhost:8081/api/books" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ 图书服务API响应正常"
else
    echo "❌ 图书服务API无响应"
fi
echo ""

# 6. 数据库连接检查
echo "6. 🗄️ 数据库连接检查："
DB_CONTAINER=$(docker ps -q -f name=postgres)
if [ -n "$DB_CONTAINER" ]; then
    echo "✅ PostgreSQL容器运行中"
    docker exec -it postgres psql -U library -d library -c "SELECT 1;" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ 数据库连接正常"
    else
        echo "❌ 数据库连接失败"
    fi
else
    echo "❌ PostgreSQL容器未运行"
fi
echo ""

echo "=== 部署检查完成 ==="