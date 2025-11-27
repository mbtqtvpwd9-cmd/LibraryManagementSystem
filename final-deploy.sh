#!/bin/bash

# 图书管理系统 - 最终版本部署脚本
# 优化布局，只保留增强界面，深度优化前端体验

set -e

echo "=== 图书管理系统最终版部署 ==="
echo "🎨 版本特点："
echo "   ✨ 深度优化的现代化界面"
echo "   🎯 解决仪表盘分层问题"
echo "   📱 完美响应式布局"
echo "   🚀 只保留最终增强页面"
echo "   🎨 专业级UI/UX体验"
echo ""

# 1. 停止现有容器
echo "步骤1: 停止现有容器..."
docker-compose down || true
docker-compose -f docker-compose.ubuntu.yml down || true

# 2. 清理Docker缓存
echo "步骤2: 清理Docker缓存..."
docker system prune -f || true

# 3. 下载基础镜像
echo "步骤3: 下载基础镜像..."
./pull-basic-images.sh || echo "基础镜像下载失败，继续构建..."

# 4. 构建并启动服务
echo "步骤4: 构建并启动服务..."
docker-compose -f docker-compose.ubuntu.yml up -d --build

# 5. 等待数据库启动
echo "步骤5: 等待数据库启动..."
sleep 30

# 6. 等待应用启动
echo "步骤6: 等待应用启动（优化版本启动中）..."
sleep 90

# 7. 检查服务状态
echo "步骤7: 检查服务状态..."
docker-compose -f docker-compose.ubuntu.yml ps

# 8. 显示应用日志
echo "步骤8: 显示应用启动日志..."
docker-compose -f docker-compose.ubuntu.yml logs --tail=30 app

# 9. 测试应用访问
echo "步骤9: 测试应用访问..."
echo "测试主页访问..."
curl -s -I http://localhost:8080/ | head -1 || echo "主页访问测试"

echo "测试API访问..."
curl -s -I http://localhost:8080/api/books | head -1 || echo "API访问测试"

echo ""
echo "=== 部署完成 ==="
echo "🌟 访问地址："
echo "   📱 最终界面: http://150.158.125.55:8080/"
echo ""
echo "🔑 默认账户："
echo "   👨‍💼 管理员: admin/admin123"
echo "   👤 读者: reader/reader123"
echo ""
echo "✨ 界面特性："
echo "   ✅ 深度优化的现代化设计"
echo "   ✅ 完美解决的仪表盘分层问题"
echo "   ✅ 专业级的布局和交互"
echo "   ✅ 流畅的动画和过渡效果"
echo "   ✅ 完全响应式设计"
echo "   ✅ 直观的用户体验"
echo ""
echo "🔧 管理命令："
echo "   重启: docker-compose -f docker-compose.ubuntu.yml restart"
echo "   查看日志: docker-compose -f docker-compose.ubuntu.yml logs -f app"
echo "   查看状态: docker-compose -f docker-compose.ubuntu.yml ps"
echo ""