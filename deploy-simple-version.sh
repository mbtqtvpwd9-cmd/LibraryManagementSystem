#!/bin/bash

echo "=== 部署简化版图书馆管理系统 ==="

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java，请先安装Java 17或更高版本"
    exit 1
fi

# 检查Maven
if ! command -v mvn &> /dev/null; then
    echo "错误: 未找到Maven，请先安装Maven"
    echo "安装命令: brew install maven"
    exit 1
fi

echo "1. 清理并编译项目..."
mvn clean compile -DskipTests

if [ $? -ne 0 ]; then
    echo "编译失败!"
    exit 1
fi

echo "2. 打包项目..."
mvn package -DskipTests

if [ $? -ne 0 ]; then
    echo "打包失败!"
    exit 1
fi

echo "3. 检查生成的JAR文件..."
JAR_FILE=$(find target -name "*.jar" -not -name "*-sources.jar" | head -1)
if [ -z "$JAR_FILE" ]; then
    echo "错误: 未找到可执行的JAR文件"
    exit 1
fi

echo "找到JAR文件: $JAR_FILE"

echo "4. 启动应用..."
echo "应用将在 http://localhost:8080 启动"
echo "默认管理员账号: admin"
echo "默认密码: admin123"
echo ""
echo "按 Ctrl+C 停止应用"
echo ""

java -jar "$JAR_FILE"