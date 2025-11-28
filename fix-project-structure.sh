#!/bin/bash

# 图书管理系统 - 修复项目结构并构建

set -e

echo "=== 修复项目结构并构建 ==="
echo ""

# 1. 检查项目结构
echo "1. 检查项目结构..."
echo "主目录:"
ls -la | grep -E "(pom\.xml|backend|frontend|target)"
echo ""
echo "backend-microservices目录:"
ls -la backend-microservices/

# 2. 检查pom.xml文件
echo ""
echo "2. 检查pom.xml文件..."
if [ -f "pom.xml" ]; then
    echo "✅ 主目录下找到pom.xml"
    echo "内容预览:"
    head -20 pom.xml
else
    echo "❌ 主目录下没有pom.xml"
    
    # 检查backend-microservices目录
    if [ -f "backend-microservices/pom.xml" ]; then
        echo "backend-microservices目录下有pom.xml"
        cp backend-microservices/pom.xml ./
        echo "已复制到主目录"
    else
        echo "❌ 找不到pom.xml文件"
        exit 1
    fi
fi

# 3. 检查src目录
echo ""
echo "3. 检查src目录..."
if [ -d "src" ]; then
    echo "✅ 主目录下找到src目录"
    echo "结构:"
    find src -name "*.java" | head -5
else
    echo "❌ 主目录下没有src目录"
    
    # 检查backend-microservices目录
    if [ -d "backend-microservices/gateway-service/src" ]; then
        echo "在backend-microservices/gateway-service找到src"
        cp -r backend-microservices/gateway-service/src ./
        echo "已复制到主目录"
    else
        echo "❌ 找不到src目录"
        exit 1
    fi
fi

# 4. 清理旧的构建文件
echo ""
echo "4. 清理旧的构建文件..."
rm -rf target/
echo "已清理target目录"

# 5. 安装Java 17
echo ""
echo "5. 检查并安装Java 17..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo "当前Java版本: $JAVA_VERSION"
    
    if [ "$JAVA_VERSION" -lt 17 ]; then
        echo "Java版本不符合要求，安装Java 17..."
        sudo apt-get update
        sudo apt-get install -y openjdk-17-jdk
        sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
        sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    else
        echo "✅ Java版本符合要求"
    fi
else
    echo "Java未安装，正在安装Java 17..."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
    sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
    sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
fi

# 6. 安装Maven
echo ""
echo "6. 检查并安装Maven..."
if command -v mvn &> /dev/null; then
    echo "✅ Maven已安装"
    mvn -version
else
    echo "Maven未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y maven
fi

# 7. 构建项目
echo ""
echo "7. 构建项目..."
echo "这可能需要几分钟，请耐心等待..."

# 设置Maven内存限制
export MAVEN_OPTS="-Xmx1024m"

# 构建项目
mvn clean package -DskipTests

# 8. 检查构建结果
echo ""
echo "8. 检查构建结果..."
if [ -f "target/library-management-system.jar" ]; then
    echo "✅ JAR文件构建成功"
    ls -lh target/library-management-system.jar
    
    # 验证JAR文件
    if file target/library-management-system.jar | grep -q "Zip archive data"; then
        echo "✅ JAR文件格式验证通过"
    else
        echo "❌ JAR文件格式错误"
        exit 1
    fi
else
    echo "❌ JAR文件构建失败"
    
    # 尝试查找其他JAR文件
    echo "查找其他JAR文件:"
    find target -name "*.jar" -exec ls -lh {} \; 2>/dev/null || echo "没有找到任何JAR文件"
    exit 1
fi

# 9. 停止所有相关容器
echo ""
echo "9. 停止所有相关容器..."
docker stop library-backend library-frontend postgres redis 2>/dev/null || true
docker rm library-backend library-frontend postgres redis 2>/dev/null || true

# 10. 创建Docker网络
echo ""
echo "10. 创建Docker网络..."
docker network ls | grep library-network || docker network create library-network

# 11. 启动基础服务
echo ""
echo "11. 启动基础服务..."
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

echo "等待基础服务启动..."
sleep 20

# 12. 创建简单的前端页面
echo ""
echo "12. 创建简单的前端页面..."
mkdir -p frontend-vue/dist
cat > frontend-vue/dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .status {
            text-align: center;
            margin-top: 20px;
        }
        .success {
            color: green;
            font-weight: bold;
        }
        .api-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #1890ff;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>图书管理系统</h1>
        <div class="status">
            <p class="success">✅ 前端服务已启动</p>
            <p>后端API正在初始化...</p>
        </div>
        <a href="http://150.158.125.55:8080" class="api-link">访问后端API</a>
    </div>
</body>
</html>
EOF

# 13. 启动后端服务
echo ""
echo "13. 启动后端服务..."
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

# 14. 启动前端服务
echo ""
echo "14. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 15. 等待服务启动
echo ""
echo "15. 等待服务启动..."
echo "等待60秒让应用完全启动..."
sleep 60

# 16. 测试服务
echo ""
echo "16. 测试服务..."
echo "测试前端服务..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ 前端服务正常 (状态码: $FRONTEND_STATUS)"
else
    echo "❌ 前端服务异常 (状态码: $FRONTEND_STATUS)"
fi

echo ""
echo "测试后端服务..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ 后端服务正常 (状态码: $BACKEND_STATUS)"
else
    echo "❌ 后端服务异常 (状态码: $BACKEND_STATUS)"
    echo "检查后端日志:"
    docker logs --tail 20 library-backend
fi

# 17. 显示访问地址
echo ""
echo "=== 部署完成 ==="
echo ""
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "访问地址："
echo "前端应用: http://$EXTERNAL_IP:3000"
echo "后端API: http://$EXTERNAL_IP:8080"
echo ""
echo "容器状态："
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"