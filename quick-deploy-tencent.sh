#!/bin/bash

# 图书管理系统 - 腾讯云快速部署脚本
# 适用于已安装Maven的Ubuntu环境

echo "=== 快速部署到腾讯云 ==="

# 快速构建和启动
echo "1. 构建项目..."
mvn clean package -DskipTests -q

echo "2. 启动服务..."
docker-compose -f docker-compose.tencent.yml down -v
docker-compose -f docker-compose.tencent.yml up -d --build

echo "3. 等待启动..."
sleep 45

echo "4. 检查状态..."
docker-compose -f docker-compose.tencent.yml ps

echo ""
echo "✅ 部署完成！"
echo "访问地址: http://localhost:8080"
echo "管理员账户: admin/admin123"