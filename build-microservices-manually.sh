#!/bin/bash

echo "=== 手动构建微服务项目 ==="

cd backend-microservices

echo "1. 构建common-service..."
cd common-service
mvn clean install -DskipTests -U
if [ $? -ne 0 ]; then
    echo "common-service 构建失败!"
    exit 1
fi
cd ..

echo "2. 构建book-service..."
cd book-service
mvn clean install -DskipTests -U
if [ $? -ne 0 ]; then
    echo "book-service 构建失败!"
    exit 1
fi
cd ..

echo "3. 构建gateway-service..."
cd gateway-service
mvn clean install -DskipTests -U
if [ $? -ne 0 ]; then
    echo "gateway-service 构建失败!"
    exit 1
fi
cd ..

echo "微服务构建完成!"
echo "现在可以运行部署脚本了"