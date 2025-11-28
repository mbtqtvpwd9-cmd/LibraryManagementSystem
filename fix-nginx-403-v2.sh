#!/bin/bash

# 图书管理系统 - 修复Nginx 403 Forbidden错误 (V2版)

set -e

echo "=== 修复Nginx 403 Forbidden错误 (V2版) ==="
echo ""

# 1. 检查前端构建输出
echo "1. 检查前端构建输出..."
if [ ! -d "frontend-vue/dist" ]; then
    echo "❌ 前端未构建，正在构建..."
    cd frontend-vue
    npm install
    npm run build
    cd ..
else
    echo "✅ 前端已构建"
fi

# 2. 检查dist目录内容
echo ""
echo "2. 检查dist目录内容..."
ls -la frontend-vue/dist/ | head -10

# 3. 修复文件权限
echo ""
echo "3. 修复文件权限..."
chmod -R 755 frontend-vue/dist/

# 4. 停止并删除旧的前端容器
echo ""
echo "4. 重建前端容器..."
docker stop library-frontend 2>/dev/null || true
docker rm library-frontend 2>/dev/null || true

# 5. 创建自定义Nginx配置
echo ""
echo "5. 创建Nginx配置..."
mkdir -p nginx-config
cat > nginx-config/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # 处理Vue Router的历史模式
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# 6. 创建一个简单的HTML页面用于测试
echo ""
echo "6. 创建测试页面..."
cat > frontend-vue/dist/test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>测试页面</title>
</head>
<body>
    <h1>测试页面 - 如果您看到这个页面，说明Nginx配置正确！</h1>
</body>
</html>
EOF

# 7. 启动新的前端容器（使用自定义配置）
echo ""
echo "7. 启动新的前端容器..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  -v $(pwd)/nginx-config/default.conf:/etc/nginx/conf.d/default.conf:ro \
  nginx:alpine

# 8. 等待容器启动
echo ""
echo "8. 等待容器启动..."
sleep 15

# 9. 测试本地访问
echo ""
echo "9. 测试本地访问..."
curl -I http://localhost:3000 || echo "❌ 本地无法访问主页"

echo ""
echo "测试测试页面访问:"
curl -I http://localhost:3000/test.html || echo "❌ 本地无法访问测试页面"

# 10. 检查容器状态
echo ""
echo "10. 检查容器状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep library-frontend

# 11. 检查容器内文件（使用timeout避免卡住）
echo ""
echo "11. 检查容器内文件..."
timeout 5 docker exec library-frontend ls -la /usr/share/nginx/html/ 2>/dev/null || echo "❌ 无法查看容器内文件"

# 12. 测试Nginx配置（使用timeout避免卡住）
echo ""
echo "12. 检查Nginx配置..."
timeout 5 docker exec library-frontend nginx -t 2>/dev/null || echo "❌ Nginx配置检查失败"

# 13. 测试外部访问
echo ""
echo "13. 测试外部访问..."
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "测试外部访问: http://$EXTERNAL_IP:3000"
curl -I --connect-timeout 5 http://$EXTERNAL_IP:3000 2>/dev/null || echo "❌ 外部无法访问"

echo ""
echo "=== 修复完成 ==="
echo ""
echo "如果仍有问题，请检查以下内容："
echo ""
echo "1. 容器是否正常运行："
echo "   docker ps | grep library-frontend"
echo ""
echo "2. 容器内部文件结构："
echo "   docker exec library-frontend ls -la /usr/share/nginx/html/"
echo ""
echo "3. 尝试访问测试页面："
echo "   http://150.158.125.55:3000/test.html"
echo ""
echo "4. 手动进入容器调试："
echo "   docker exec -it library-frontend /bin/sh"
echo "   cat /var/log/nginx/error.log | tail -10"