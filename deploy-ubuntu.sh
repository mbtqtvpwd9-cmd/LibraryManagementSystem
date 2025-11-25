#!/bin/bash

# 图书管理系统 - Ubuntu版本部署脚本
# 使用Ubuntu基础镜像，避免Maven镜像网络问题

set -e

echo "=== 图书管理系统Ubuntu版本部署 ==="

# 步骤1: 下载基础镜像
echo "步骤1: 下载基础镜像..."
./pull-basic-images.sh

# 步骤2: 停止现有容器
echo "步骤2: 停止现有容器..."
docker-compose down || true
docker-compose -f docker-compose.ubuntu.yml down || true

# 步骤3: 启动服务
echo "步骤3: 构建并启动服务..."
docker-compose -f docker-compose.ubuntu.yml up -d --build

# 步骤4: 等待服务启动
echo "步骤4: 等待服务启动..."
echo "等待数据库启动..."
sleep 20
echo "等待应用启动..."
sleep 40

# 步骤5: 检查服务状态
echo "步骤5: 检查服务状态..."
docker-compose -f docker-compose.ubuntu.yml ps

# 步骤6: 显示应用日志
echo "步骤6: 显示应用启动日志..."
docker-compose -f docker-compose.ubuntu.yml logs app

echo ""
echo "=== 部署完成 ==="
echo "应用访问地址: http://localhost:8080"
echo "数据库地址: localhost:3306"
echo ""
echo "默认账户："
echo "管理员: admin/admin123"
echo "读者: reader/reader123"