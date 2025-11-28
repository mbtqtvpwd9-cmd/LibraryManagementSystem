#!/bin/bash

# 图书管理系统 - 前端快速部署脚本

set -e

echo "=== 前端快速部署 ==="

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ Node.js未安装，请先运行quick-deploy.sh安装环境"
    exit 1
fi

# 进入前端目录
cd frontend-vue

# 安装依赖
echo "📦 安装前端依赖..."
npm install

# 构建前端
echo "🔨 构建前端应用..."
npm run build

# 返回根目录
cd ..

# 停止并删除旧容器
echo "🧹 清理旧容器..."
docker stop library-frontend 2>/dev/null || true
docker rm library-frontend 2>/dev/null || true

# 启动新容器
echo "🚀 启动前端容器..."
docker run -d --name library-frontend \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

echo ""
echo "✅ 前端部署完成！"
echo ""
echo "🌐 访问地址: http://150.158.125.55:3000/"
echo ""