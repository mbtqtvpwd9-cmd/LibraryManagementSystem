#!/bin/bash

# 不使用Docker直接运行应用
# 适用于Docker不可用的情况

echo "=== 不使用Docker运行图书管理系统 ==="

# 1. 检查Java环境
echo "1. 检查Java环境..."
if ! command -v java &> /dev/null; then
    echo "错误: Java未安装"
    exit 1
fi

java -version

# 2. 检查JAR文件
echo "2. 检查JAR文件..."
if [ ! -f "target/library-management-system-1.0.0.jar" ]; then
    echo "JAR文件不存在，开始构建..."
    ./build-simple-from-microservices.sh
fi

if [ ! -f "target/library-management-system-1.0.0.jar" ]; then
    echo "错误: 无法构建JAR文件"
    exit 1
fi

echo "✓ JAR文件存在"

# 3. 检查MySQL
echo "3. 检查MySQL..."
if command -v mysql &> /dev/null; then
    echo "✓ MySQL已安装"
    # 尝试连接本地MySQL
    if mysql -u root -e "SELECT 1;" &>/dev/null; then
        echo "✓ MySQL连接正常"
        # 创建数据库
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS library_db;" 2>/dev/null || true
    else
        echo "⚠ MySQL需要配置"
    fi
else
    echo "⚠ MySQL未安装，将使用H2内存数据库"
fi

# 4. 启动应用
echo "4. 启动应用..."
echo "使用H2内存数据库启动..."

# 设置环境变量使用H2
export SPRING_PROFILES_ACTIVE=h2
export SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb
export SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver
export SPRING_DATASOURCE_USERNAME=sa
export SPRING_DATASOURCE_PASSWORD=
export SPRING_H2_CONSOLE_ENABLED=true

# 启动应用
java -jar target/library-management-system-1.0.0.jar &
APP_PID=$!

echo "应用已启动，PID: $APP_PID"
echo "等待应用启动..."
sleep 30

# 5. 检查应用状态
echo "5. 检查应用状态..."
if curl -f http://localhost:8080/api/users/login &> /dev/null; then
    echo "✅ 应用启动成功！"
    echo "访问地址: http://localhost:8080"
    echo "H2控制台: http://localhost:8080/h2-console"
    echo ""
    echo "默认账户："
    echo "管理员: admin/admin123"
    echo "读者: reader/reader123"
    echo ""
    echo "停止应用: kill $APP_PID"
else
    echo "⚠ 应用可能还在启动中，请稍后检查"
    echo "查看日志: tail -f nohup.out"
fi

# 保存PID
echo $APP_PID > app.pid
echo "应用PID已保存到 app.pid"