#!/bin/bash

# 图书管理系统 - 检查外部访问

set -e

echo "=== 检查外部访问状态 ==="
echo ""

# 1. 获取服务器IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "服务器IP: $EXTERNAL_IP"

# 2. 测试本地访问
echo ""
echo "1. 测试本地访问..."
LOCAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
if [ "$LOCAL_STATUS" = "200" ]; then
    echo "✅ 本地访问正常 (状态码: $LOCAL_STATUS)"
else
    echo "❌ 本地访问异常 (状态码: $LOCAL_STATUS)"
fi

# 3. 测试外部访问
echo ""
echo "2. 测试外部访问..."
EXTERNAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP:3000 2>/dev/null || echo "000")
if [ "$EXTERNAL_STATUS" = "200" ]; then
    echo "✅ 外部访问正常 (状态码: $EXTERNAL_STATUS)"
    echo "🎉 您可以通过以下URL访问应用："
    echo "   http://$EXTERNAL_IP:3000"
else
    echo "❌ 外部访问异常 (状态码: $EXTERNAL_STATUS)"
    echo ""
    echo "可能的原因："
    echo "1. 腾讯云安全组未开放3000端口"
    echo "2. 服务器防火墙阻止了3000端口"
    echo ""
    echo "请检查以下配置："
    echo "1. 腾讯云控制台 > 安全组 > 添加规则："
    echo "   - 类型：自定义"
    echo "   - 来源：0.0.0.0/0"
    echo "   - 协议端口：TCP:3000"
    echo "   - 策略：允许"
    echo ""
    echo "2. 服务器防火墙设置："
    echo "   sudo ufw status"
    echo "   sudo ufw allow 3000/tcp"
    echo "   sudo ufw reload"
fi

# 4. 检查容器状态
echo ""
echo "3. 检查容器状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep library-frontend || echo "❌ library-frontend 容器未运行"

# 5. 检查后端服务
echo ""
echo "4. 检查后端服务..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ 后端服务正常 (状态码: $BACKEND_STATUS)"
    
    # 测试外部后端访问
    BACKEND_EXTERNAL=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP:8080 2>/dev/null || echo "000")
    if [ "$BACKEND_EXTERNAL" = "200" ]; then
        echo "✅ 后端外部访问正常 (状态码: $BACKEND_EXTERNAL)"
    else
        echo "❌ 后端外部访问异常 (状态码: $BACKEND_EXTERNAL)"
    fi
else
    echo "❌ 后端服务异常 (状态码: $BACKEND_STATUS)"
fi

echo ""
echo "=== 检查完成 ==="