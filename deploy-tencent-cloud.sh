#!/bin/bash

# 图书管理系统 - 腾讯云Ubuntu服务器部署脚本
# 适用于已安装Maven的Ubuntu 22.04 + Docker 26环境

set -e

echo "=== 图书管理系统 - 腾讯云部署 ==="

# 检查环境
echo "步骤1: 检查环境..."
if ! command -v mvn &> /dev/null; then
    echo "错误: Maven未安装，请先安装Maven"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

echo "✓ 环境检查通过"

# 步骤2: 清理之前的构建
echo "步骤2: 清理之前的构建..."
mvn clean
docker-compose down || true
docker system prune -f

# 步骤3: 使用本地Maven构建
echo "步骤3: 使用本地Maven构建项目..."
mvn package -DskipTests

# 步骤4: 构建Docker镜像
echo "步骤4: 构建Docker镜像..."
docker build -t library-management-system:latest .

# 步骤5: 启动服务
echo "步骤5: 启动服务..."
docker-compose -f docker-compose.tencent.yml up -d

# 步骤6: 等待服务启动
echo "步骤6: 等待服务启动..."
echo "等待数据库启动..."
sleep 30
echo "等待应用启动..."
sleep 60

# 步骤7: 健康检查
echo "步骤7: 健康检查..."
if curl -f http://localhost:8080/api/users/login &> /dev/null; then
    echo "✓ 应用启动成功"
else
    echo "⚠ 应用可能还在启动中，请稍后检查"
fi

# 步骤8: 显示状态
echo "步骤8: 显示服务状态..."
docker-compose -f docker-compose.tencent.yml ps

echo ""
echo "=== 部署完成 ==="
echo "应用访问地址: http://localhost:8080"
echo "数据库地址: localhost:3306"
echo ""
echo "默认账户："
echo "管理员: admin/admin123"
echo "读者: reader/reader123"
echo ""
echo "查看日志: docker-compose -f docker-compose.tencent.yml logs -f app"
echo "停止服务: docker-compose -f docker-compose.tencent.yml down"