#!/bin/bash

# 图书管理系统 - 修复损坏的JAR文件

set -e

echo "=== 修复损坏的JAR文件 ==="
echo ""

# 1. 检查JAR文件
echo "1. 检查JAR文件..."
if [ -f "target/library-management-system.jar" ]; then
    echo "JAR文件存在，检查文件大小和状态..."
    ls -lh target/library-management-system.jar
    
    # 尝试检查JAR文件是否有效
    if file target/library-management-system.jar | grep -q "Zip archive data"; then
        echo "✅ JAR文件格式正确"
    else
        echo "❌ JAR文件格式错误，需要重新构建"
    fi
else
    echo "❌ JAR文件不存在"
fi

# 2. 检查Java版本
echo ""
echo "2. 检查Java版本..."
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
echo "当前Java版本: $JAVA_VERSION"

# 检查Java是否为17
if [[ "$JAVA_VERSION" == 17* ]]; then
    echo "✅ Java版本符合要求"
else
    echo "❌ Java版本不符合要求，正在安装Java 17..."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
    sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
    sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc
    echo "✅ Java 17安装完成"
fi

# 3. 停止并删除后端容器
echo ""
echo "3. 停止并删除后端容器..."
docker stop library-backend 2>/dev/null || echo "没有运行中的library-backend容器"
docker rm library-backend 2>/dev/null || echo "没有需要删除的library-backend容器"

# 4. 清理旧的构建文件
echo ""
echo "4. 清理旧的构建文件..."
rm -rf target/
echo "已删除target目录"

# 5. 重新构建项目
echo ""
echo "5. 重新构建项目..."
echo "这可能需要几分钟时间，请耐心等待..."

# 设置Maven内存限制
export MAVEN_OPTS="-Xmx1024m"

# 构建项目
mvn clean package -DskipTests

# 6. 检查新构建的JAR文件
echo ""
echo "6. 检查新构建的JAR文件..."
if [ -f "target/library-management-system.jar" ]; then
    echo "✅ JAR文件构建成功"
    ls -lh target/library-management-system.jar
    
    # 验证JAR文件
    if file target/library-management-system.jar | grep -q "Zip archive data"; then
        echo "✅ JAR文件格式验证通过"
    else
        echo "❌ JAR文件格式仍然错误"
        exit 1
    fi
else
    echo "❌ JAR文件构建失败"
    exit 1
fi

# 7. 启动后端容器
echo ""
echo "7. 启动后端容器..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  -e SPRING_REDIS_HOST=redis \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 8. 等待容器启动
echo ""
echo "8. 等待容器启动..."
sleep 60

# 9. 检查容器状态
echo ""
echo "9. 检查容器状态..."
CONTAINER_STATUS=$(docker ps --format "{{.Names}}\t{{.Status}}" | grep library-backend)
if [ -n "$CONTAINER_STATUS" ]; then
    echo "✅ 容器运行中:"
    echo "$CONTAINER_STATUS"
else
    echo "❌ 容器未运行，检查日志..."
    docker logs --tail 20 library-backend
fi

# 10. 测试本地连接
echo ""
echo "10. 测试本地连接..."
for i in {1..5}; do
    LOCAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
    if [ "$LOCAL_STATUS" = "200" ]; then
        echo "✅ 本地连接成功 (状态码: $LOCAL_STATUS)"
        break
    else
        echo "⏳ 本地连接尝试 $i/5 (状态码: $LOCAL_STATUS)"
        if [ $i -lt 5 ]; then
            sleep 10
        else
            echo "❌ 本地连接失败，检查日志..."
            docker logs --tail 30 library-backend
        fi
    fi
done

# 11. 测试外部连接
echo ""
echo "11. 测试外部连接..."
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
EXTERNAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP:8080 2>/dev/null || echo "000")
if [ "$EXTERNAL_STATUS" = "200" ]; then
    echo "✅ 外部连接成功 (状态码: $EXTERNAL_STATUS)"
    echo "🎉 后端服务已成功部署并可外部访问！"
    echo ""
    echo "📊 后端API: http://$EXTERNAL_IP:8080"
    echo "🌐 前端应用: http://$EXTERNAL_IP:3000"
else
    echo "❌ 外部连接失败 (状态码: $EXTERNAL_STATUS)"
    echo "请检查防火墙设置："
    echo "   sudo ufw status"
    echo "   sudo ufw allow 8080/tcp"
fi

echo ""
echo "=== 修复完成 ==="