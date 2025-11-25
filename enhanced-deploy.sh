#!/bin/bash

# 图书管理系统 - 增强功能部署脚本
# 包含完整的图书管理、借阅管理和美观界面

set -e

echo "=== 图书管理系统增强版部署 ==="
echo "✨ 新功能："
echo "   - 完整的图书编辑功能"
echo "   - 网格/列表视图切换"
echo "   - 借阅管理系统"
echo "   - 美观的现代化界面"
echo "   - 统计报表功能"
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
echo "步骤6: 等待应用启动（这可能需要2-3分钟）..."
sleep 120

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

echo "测试增强界面访问..."
curl -s -I http://localhost:8080/enhanced-index.html | head -1 || echo "增强界面访问测试"

echo "测试API访问..."
curl -s -I http://localhost:8080/api/books | head -1 || echo "API访问测试"

echo ""
echo "=== 部署完成 ==="
echo "🌟 访问地址："
echo "   📱 标准界面: http://150.158.125.55:8080/"
echo "   ✨ 增强界面: http://150.158.125.55:8080/enhanced-index.html"
echo ""
echo "🔑 默认账户："
echo "   👨‍💼 管理员: admin/admin123"
echo "   👤 读者: reader/reader123"
echo ""
echo "🆕 新功能特性："
echo "   ✅ 完整的图书CRUD操作"
echo "   ✅ 网格和列表双视图模式"
echo "   ✅ 高级搜索和筛选"
echo "   ✅ 图书分类管理"
echo "   ✅ 借阅管理系统"
echo "   ✅ 统计报表仪表盘"
echo "   ✅ 响应式现代化界面"
echo ""
echo "🔧 管理命令："
echo "   重启: docker-compose -f docker-compose.ubuntu.yml restart"
echo "   查看日志: docker-compose -f docker-compose.ubuntu.yml logs -f app"
echo "   查看状态: docker-compose -f docker-compose.ubuntu.yml ps"
echo ""