#!/bin/bash

# 图书管理系统 - 基础镜像下载脚本
# 只下载最基础、最稳定的镜像

echo "开始下载基础Docker镜像..."

# 只下载Ubuntu和MySQL基础镜像
echo "1. 下载Ubuntu基础镜像..."
docker pull ubuntu:22.04

echo "2. 下载MySQL数据库镜像..."
docker pull mysql:8.0

# 检查下载结果
echo ""
echo "基础镜像下载完成，检查结果："
docker images | grep -E "(ubuntu|mysql)"

echo ""
echo "基础镜像已准备就绪，现在可以运行："
echo "docker-compose -f docker-compose.ubuntu.yml up -d"