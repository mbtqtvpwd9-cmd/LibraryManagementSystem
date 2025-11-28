#!/bin/bash

# 图书管理系统 - 快速修复Nginx 403错误

set -e

echo "=== 快速修复Nginx 403错误 ==="
echo ""

# 1. 检查容器状态
echo "1. 检查容器状态..."
docker ps | grep library-frontend || echo "❌ library-frontend 容器未运行"

# 2. 检查dist目录
echo ""
echo "2. 检查dist目录..."
if [ -d "frontend-vue/dist" ]; then
    echo "✅ dist目录存在"
    ls -la frontend-vue/dist/ | head -5
else
    echo "❌ dist目录不存在，正在构建前端..."
    cd frontend-vue
    npm install
    npx vite build --mode production
    cd ..
fi

# 3. 修复文件权限
echo ""
echo "3. 修复文件权限..."
chmod -R 755 frontend-vue/dist/

# 4. 创建一个简单的index.html（如果不存在）
echo ""
echo "4. 检查index.html..."
if [ ! -f "frontend-vue/dist/index.html" ]; then
    echo "创建简单的index.html..."
    mkdir -p frontend-vue/dist
    cat > frontend-vue/dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>
</head>
<body>
    <div id="app">
        <h1>图书管理系统</h1>
        <p>系统正在加载中...</p>
    </div>
    <script>
        console.log('Nginx容器正常运行，但前端应用可能存在问题');
    </script>
</body>
</html>
EOF
fi

# 5. 停止并重建容器
echo ""
echo "5. 重建容器..."
docker stop library-frontend 2>/dev/null || true
docker rm library-frontend 2>/dev/null || true

# 6. 使用最简单的方式启动Nginx
echo ""
echo "6. 启动Nginx容器..."
docker run -d --name library-frontend \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 7. 等待容器启动
echo ""
echo "7. 等待容器启动..."
sleep 10

# 8. 测试本地访问
echo ""
echo "8. 测试本地访问..."
curl -I http://localhost:3000 || echo "❌ 本地无法访问"

# 9. 检查容器内部
echo ""
echo "9. 检查容器内部..."
docker exec library-frontend ls -la /usr/share/nginx/html/ || echo "❌ 无法查看容器内文件"

# 10. 测试外部访问
echo ""
echo "10. 测试外部访问..."
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "测试外部访问: http://$EXTERNAL_IP:3000"
curl -I --connect-timeout 5 http://$EXTERNAL_IP:3000 2>/dev/null || echo "❌ 外部无法访问"

echo ""
echo "=== 修复完成 ==="
echo ""
echo "如果仍然无法访问，可以尝试："
echo ""
echo "1. 进入容器检查："
echo "   docker exec -it library-frontend /bin/sh"
echo "   cat /etc/nginx/conf.d/default.conf"
echo ""
echo "2. 手动测试容器内文件："
echo "   docker exec library-frontend cat /usr/share/nginx/html/index.html"
echo ""
echo "3. 检查防火墙设置："
echo "   sudo ufw status"
echo "   sudo ufw allow 3000"