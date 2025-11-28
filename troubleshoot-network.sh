#!/bin/bash

# 图书管理系统 - 网络问题排查脚本

set -e

echo "=== 图书管理系统网络问题排查 ==="
echo ""

# 1. 检查容器状态
echo "1. 容器状态检查："
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# 2. 检查容器端口绑定
echo "2. 容器端口绑定检查："
docker inspect library-frontend --format='{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}} -> {{(index $conf 0).HostPort}}{{"\n"}}{{end}}{{end}}' 2>/dev/null || echo "❌ library-frontend 容器不存在"
docker inspect library-backend --format='{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}} -> {{(index $conf 0).HostPort}}{{"\n"}}{{end}}{{end}}' 2>/dev/null || echo "❌ library-backend 容器不存在"
echo ""

# 3. 检查本地端口访问
echo "3. 本地端口访问测试："
echo "前端本地访问："
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:3000 || echo "❌ 本地无法访问端口3000"

echo "后端本地访问："
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8080 || echo "❌ 本地无法访问端口8080"
echo ""

# 4. 检查端口监听
echo "4. 端口监听状态："
netstat -tulpn | grep :3000 || echo "❌ 端口3000未监听"
netstat -tulpn | grep :8080 || echo "❌ 端口8080未监听"
echo ""

# 5. 重建容器（修复端口绑定问题）
echo "5. 重建容器以修复端口绑定..."

# 停止并删除容器
docker stop library-frontend library-backend 2>/dev/null || true
docker rm library-frontend library-backend 2>/dev/null || true

# 启动后端（使用0.0.0.0绑定）
echo "启动后端服务（绑定到0.0.0.0）..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 启动前端（使用0.0.0.0绑定）
echo "启动前端服务（绑定到0.0.0.0）..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 6. 等待容器启动
echo ""
echo "6. 等待服务启动..."
sleep 30

# 7. 再次检查端口监听
echo "7. 再次检查端口监听状态："
netstat -tulpn | grep :3000 || echo "❌ 端口3000仍未监听"
netstat -tulpn | grep :8080 || echo "❌ 端口8080仍未监听"
echo ""

# 8. 测试本地访问
echo "8. 测试本地访问："
echo "前端本地访问："
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:3000 || echo "❌ 本地无法访问端口3000"

echo "后端本地访问："
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8080 || echo "❌ 本地无法访问端口8080"
echo ""

# 9. 测试外部访问
echo "9. 测试外部访问："
EXTERNAL_IP=$(curl -s ifconfig.me || echo "150.158.125.55")
echo "服务器IP: $EXTERNAL_IP"

echo "前端外部访问："
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://$EXTERNAL_IP:3000 || echo "❌ 外部无法访问端口3000"

echo "后端外部访问："
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://$EXTERNAL_IP:8080 || echo "❌ 外部无法访问端口8080"
echo ""

# 10. 检查容器日志
echo "10. 检查容器日志（最后10行）："
echo "--- 前端日志 ---"
docker logs --tail 10 library-frontend 2>/dev/null || echo "❌ 前端容器不存在"

echo ""
echo "--- 后端日志 ---"
docker logs --tail 10 library-backend 2>/dev/null || echo "❌ 后端容器不存在"

echo ""
echo "=== 排查完成 ==="
echo ""
echo "如果仍然无法访问，可能的原因："
echo "1. 腾讯云安全组配置问题"
echo "2. 服务器防火墙阻止了端口"
echo "3. 应用程序内部配置问题"
echo ""
echo "手动检查防火墙："
echo "  sudo ufw status"
echo "  sudo ufw allow 3000/tcp"
echo "  sudo ufw allow 8080/tcp"