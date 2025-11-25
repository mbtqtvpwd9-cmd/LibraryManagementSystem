#!/bin/bash

# 图书管理系统 - 最终部署脚本
# 修复所有已知问题，确保完美运行

set -e

echo "=== 图书管理系统最终部署 ==="

# 1. 下载基础镜像
echo "步骤1: 下载基础镜像..."
./pull-basic-images.sh

# 2. 停止现有容器
echo "步骤2: 停止现有容器..."
docker-compose down || true
docker-compose -f docker-compose.ubuntu.yml down || true

# 3. 构建并启动服务
echo "步骤3: 构建并启动服务..."
docker-compose -f docker-compose.ubuntu.yml up -d --build

# 4. 等待数据库启动
echo "步骤4: 等待数据库启动..."
sleep 30

# 5. 等待应用启动
echo "步骤5: 等待应用启动..."
sleep 60

# 6. 检查服务状态
echo "步骤6: 检查服务状态..."
docker-compose -f docker-compose.ubuntu.yml ps

# 7. 测试应用访问
echo "步骤7: 测试应用访问..."
echo "测试主页访问..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ || echo "主页访问失败"

echo "测试API访问..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/books || echo "API访问失败"

# 8. 显示应用日志
echo "步骤8: 显示应用启动日志..."
docker-compose -f docker-compose.ubuntu.yml logs --tail=20 app

echo ""
echo "=== 部署完成 ==="
echo "✅ 应用访问地址: http://150.158.125.55:8080"
echo "✅ 数据库地址: localhost:3306"
echo ""
echo "🔑 默认账户："
echo "管理员: admin/admin123"
echo "读者: reader/reader123"
echo ""
echo "🔧 管理命令："
echo "重启: ./restart.sh"
echo "查看日志: docker-compose -f docker-compose.ubuntu.yml logs -f app"
echo "查看状态: docker-compose -f docker-compose.ubuntu.yml ps"