#!/bin/bash

# 图书管理系统 - 开机自启动配置脚本

echo "=== 配置图书管理系统开机自启动 ==="

# 1. 确保Docker服务开机自启动
echo "1. 设置Docker服务开机自启动..."
sudo systemctl enable docker
sudo systemctl start docker

# 2. 创建系统服务文件
echo "2. 创建图书管理系统服务..."
sudo tee /etc/systemd/system/library-management-system.service > /dev/null <<EOF
[Unit]
Description=Library Management System
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root/LibraryManagementSystem
ExecStart=/usr/local/bin/docker-compose -f docker-compose.autostart.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.autostart.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# 3. 设置服务开机自启动
echo "3. 启用图书管理系统服务..."
sudo systemctl daemon-reload
sudo systemctl enable library-management-system

# 4. 检查服务状态
echo "4. 检查服务状态..."
sudo systemctl status library-management-system --no-pager

echo ""
echo "=== 配置完成 ==="
echo "图书管理系统现在会在服务器开机后自动启动"
echo ""
echo "手动管理命令："
echo "启动服务: sudo systemctl start library-management-system"
echo "停止服务: sudo systemctl stop library-management-system"
echo "重启服务: sudo systemctl restart library-management-system"
echo "查看状态: sudo systemctl status library-management-system"