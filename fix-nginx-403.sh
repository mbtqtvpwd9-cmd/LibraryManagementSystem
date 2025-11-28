#!/bin/bash

# 图书管理系统 - 修复Nginx 403 Forbidden错误

set -e

echo "=== 修复Nginx 403 Forbidden错误 ==="
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
ls -la frontend-vue/dist/

# 3. 检查文件权限
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

# 6. 启动新的前端容器（使用自定义配置）
echo ""
echo "6. 启动新的前端容器..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  -v $(pwd)/nginx-config/default.conf:/etc/nginx/conf.d/default.conf:ro \
  nginx:alpine

# 7. 等待容器启动
echo ""
echo "7. 等待容器启动..."
sleep 10

# 8. 测试本地访问
echo ""
echo "8. 测试本地访问..."
curl -I http://localhost:3000 || echo "❌ 本地无法访问"

# 9. 检查容器内文件
echo ""
echo "9. 检查容器内文件..."
docker exec library-frontend ls -la /usr/share/nginx/html/ || echo "❌ 无法查看容器内文件"

# 10. 检查Nginx错误日志
echo ""
echo "10. 检查Nginx错误日志..."
docker exec library-frontend cat /var/log/nginx/error.log || echo "❌ 无法查看Nginx错误日志"

# 11. 测试外部访问
echo ""
echo "11. 测试外部访问..."
EXTERNAL_IP=$(curl -s ifconfig.me || echo "150.158.125.55")
echo "测试外部访问: http://$EXTERNAL_IP:3000"
curl -I http://$EXTERNAL_IP:3000 || echo "❌ 外部无法访问"

echo ""
echo "=== 修复完成 ==="
echo ""
echo "如果仍有问题，请检查："
echo "1. 前端是否正确构建"
echo "2. 文件权限是否正确"
echo "3. Nginx配置是否正确"
echo ""
echo "手动检查命令："
echo "  docker exec -it library-frontend /bin/sh"
echo "  ls -la /usr/share/nginx/html/"
echo "  cat /etc/nginx/conf.d/default.conf"