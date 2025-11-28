#!/bin/bash

# 图书管理系统 - BUG修复部署脚本
# 修复角色区分问题和分页问题

set -e

echo "=== 图书管理系统BUG修复部署 ==="
echo "🔧 本次修复："
echo "   ✅ 修复角色选择不区分问题"
echo "   ✅ 实现正确的角色验证"
echo "   ✅ 修复图书列表分页功能"
echo "   ✅ 添加分页控件和导航"
echo "   ✅ 优化用户权限控制"
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
echo "步骤6: 等待应用启动（BUG修复版本启动中）..."
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

echo "测试管理员登录..."
curl -s -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"admin123","role":"ADMIN"}' | head -3 || echo "管理员登录测试"

echo "测试读者登录..."
curl -s -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"reader","password":"reader123","role":"READER"}' | head -3 || echo "读者登录测试"

echo ""
echo "=== 部署完成 ==="
echo "🌟 访问地址："
echo "   📱 BUG修复版界面: http://150.158.125.55:8080/"
echo ""
echo "🔑 默认账户："
echo "   👨‍💼 管理员: admin/admin123 (选择管理员角色)"
echo "   👤 读者: reader/reader123 (选择读者角色)"
echo ""
echo "✨ 本次修复："
echo "   ✅ 角色选择必须匹配用户实际角色"
echo "   ✅ 错误角色选择会被拒绝"
echo "   ✅ 图书列表支持完整分页"
echo "   ✅ 分页控件美观易用"
echo "   ✅ 权限控制更严格"
echo ""
echo "🔧 测试步骤："
echo "   1. 用admin账户登录，必须选择管理员角色"
echo "   2. 用reader账户登录，必须选择读者角色"
echo "   3. 在图书管理中测试分页功能"
echo ""
echo "🔧 管理命令："
echo "   重启: docker-compose -f docker-compose.ubuntu.yml restart"
echo "   查看日志: docker-compose -f docker-compose.ubuntu.yml logs -f app"
echo "   查看状态: docker-compose -f docker-compose.ubuntu.yml ps"
echo ""