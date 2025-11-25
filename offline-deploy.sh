#!/bin/bash

# 图书管理系统 - 离线部署脚本
# 解决网络延时问题，确保部署成功

set -e

echo "=== 图书管理系统离线部署 ==="

# 步骤1: 下载所需镜像
echo "步骤1: 下载Docker镜像..."
./pull-images.sh

# 步骤2: 构建应用镜像
echo "步骤2: 构建应用镜像..."
docker build -t library-management-system:latest .

# 步骤3: 停止现有容器
echo "步骤3: 停止现有容器..."
docker-compose down || true

# 步骤4: 启动服务（使用离线配置）
echo "步骤4: 启动服务..."
docker-compose -f docker-compose.offline.yml up -d

# 步骤5: 等待服务启动
echo "步骤5: 等待服务启动..."
sleep 30

# 步骤6: 检查服务状态
echo "步骤6: 检查服务状态..."
docker-compose -f docker-compose.offline.yml ps

# 步骤7: 显示日志
echo "步骤7: 显示应用启动日志..."
docker-compose -f docker-compose.offline.yml logs app

echo ""
echo "=== 部署完成 ==="
echo "应用访问地址: http://localhost:8080"
echo "默认管理员账户: admin/admin123"
echo "默认读者账户: reader/reader123"