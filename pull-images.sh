#!/bin/bash

# 图书管理系统 - Docker镜像预下载脚本
# 用于提前下载所有需要的Docker镜像，避免部署时网络延时

echo "开始下载Docker镜像..."

# 基础镜像
echo "1. 下载Maven构建镜像..."
docker pull maven:3.9-openjdk-17

echo "2. 下载OpenJDK运行时镜像..."
docker pull openjdk:17-jdk-slim

echo "3. 下载MySQL数据库镜像..."
docker pull mysql:8.0

# 检查下载结果
echo ""
echo "镜像下载完成，检查结果："
docker images | grep -E "(maven|openjdk|mysql)"

echo ""
echo "所有镜像已准备就绪，现在可以运行 docker-compose up -d"