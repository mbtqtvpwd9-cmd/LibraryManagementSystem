#!/bin/bash

# 图书管理系统 - Java版本修复部署脚本

set -e

echo "=== 图书管理系统Java版本修复部署 ==="
echo ""

# 1. 检查并安装Java 17
echo "1. 检查并安装Java 17..."
JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
echo "当前Java版本: $JAVA_VERSION"

if [ "$JAVA_VERSION" -lt 17 ]; then
    echo "❌ Java版本低于17，正在安装Java 17..."
    
    # 更新包列表
    sudo apt-get update
    
    # 安装OpenJDK 17
    sudo apt-get install -y openjdk-17-jdk
    
    # 设置Java 17为默认版本
    sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
    sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
    
    # 设置JAVA_HOME
    echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    
    echo "✅ Java 17安装完成"
else
    echo "✅ Java版本符合要求"
fi

# 验证Java版本
echo "2. 验证Java版本..."
java -version
javac -version

# 3. 设置Maven使用Java 17
echo "3. 配置Maven使用Java 17..."
if [ ! -f ~/.m2/toolchains.xml ]; then
    mkdir -p ~/.m2
    cat > ~/.m2/toolchains.xml << EOF
<?xml version="1.0" encoding="UTF8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>17</version>
      <vendor>openjdk</vendor>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-17-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF
    echo "✅ Maven工具链配置完成"
fi

# 4. 停止并删除旧容器
echo "4. 清理旧容器..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 5. 创建Docker网络
echo "5. 创建Docker网络..."
docker network create library-network 2>/dev/null || echo "网络已存在"

# 6. 启动基础服务
echo "6. 启动基础服务..."
docker run -d --name postgres \
  --network library-network \
  -e POSTGRES_DB=library \
  -e POSTGRES_USER=library \
  -e POSTGRES_PASSWORD=library123 \
  -p 5432:5432 \
  postgres:15

docker run -d --name redis \
  --network library-network \
  -p 6379:6379 \
  redis:7-alpine

# 7. 等待基础服务启动
echo "7. 等待基础服务启动..."
sleep 30

# 8. 构建项目
echo "8. 构建项目..."
mvn clean package -DskipTests

# 9. 启动后端服务
echo "9. 启动后端服务..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar /app.jar

# 10. 构建并启动前端
echo "10. 构建前端应用..."
cd frontend-vue
npm install
npm run build
cd ..

echo "11. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 12. 等待服务启动
echo "12. 等待服务启动..."
sleep 45

# 13. 检查服务状态
echo "13. 检查服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 14. 测试服务访问
echo "14. 测试服务访问..."
echo "前端应用 (3000端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:3000 || echo "❌ 前端服务不可访问"

echo "后端服务 (8080端口):"
curl -s -o /dev/null -w "状态码: %{http_code}\n" http://localhost:8080 || echo "❌ 后端服务不可访问"

echo ""
echo "✅ 部署完成！"
echo ""
echo "🌐 访问地址："
echo "   前端应用: http://150.158.125.55:3000/"
echo "   后端API: http://150.158.125.55:8080/"
echo ""
echo "🔧 查看日志命令："
echo "   前端日志: docker logs library-frontend"
echo "   后端日志: docker logs library-backend"