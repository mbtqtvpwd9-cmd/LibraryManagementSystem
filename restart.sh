#!/bin/bash

# 图书管理系统 - 快速重启脚本

echo "=== 重启图书管理系统 ==="

# 进入项目目录
cd /root/LibraryManagementSystem

# 显示当前状态
echo "当前服务状态："
docker-compose -f docker-compose.ubuntu.yml ps

echo ""
echo "正在重启服务..."

# 重启服务
docker-compose -f docker-compose.ubuntu.yml restart

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 检查重启后状态
echo ""
echo "重启后服务状态："
docker-compose -f docker-compose.ubuntu.yml ps

# 显示应用日志（最后20行）
echo ""
echo "应用启动日志："
docker-compose -f docker-compose.ubuntu.yml logs --tail=20 app

echo ""
echo "=== 重启完成 ==="
echo "应用访问地址: http://您的服务器IP:8080"
echo "默认管理员账户: admin/admin123"
echo "默认读者账户: reader/reader123"