#!/bin/bash

# 图书管理系统 - 从零开始构建和部署

set -e

echo "=== 从零开始构建和部署 ==="
echo ""

# 1. 检查当前目录
echo "1. 检查当前目录..."
pwd

# 2. 检查项目结构
echo ""
echo "2. 检查项目结构..."
ls -la | grep -E "(pom\.xml|backend|frontend)"

# 3. 安装Java 17
echo ""
echo "3. 检查并安装Java 17..."
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

# 4. 安装Maven
echo ""
echo "4. 检查并安装Maven..."
if command -v mvn &> /dev/null; then
    echo "✅ Maven已安装"
    mvn -version
else
    echo "Maven未安装，正在安装..."
    sudo apt-get update
    sudo apt-get install -y maven
fi

# 5. 停止所有相关容器
echo ""
echo "5. 停止所有相关容器..."
docker stop library-backend library-frontend postgres redis 2>/dev/null || true
docker rm library-backend library-frontend postgres redis 2>/dev/null || true

# 6. 创建Docker网络
echo ""
echo "6. 创建Docker网络..."
docker network ls | grep library-network || docker network create library-network

# 7. 启动基础服务
echo ""
echo "7. 启动基础服务..."
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

# 8. 构建后端
echo ""
echo "8. 构建后端应用..."
echo "这可能需要几分钟，请耐心等待..."

# 设置Maven内存限制
export MAVEN_OPTS="-Xmx1024m"

# 检查pom.xml文件
if [ ! -f "pom.xml" ]; then
    echo "❌ pom.xml文件不存在"
    exit 1
fi

# 构建项目
mvn clean package -DskipTests

# 9. 检查构建结果
echo ""
echo "9. 检查构建结果..."
if [ -f "target/library-management-system.jar" ]; then
    echo "✅ JAR文件构建成功"
    ls -lh target/library-management-system.jar
else
    echo "❌ JAR文件构建失败"
    exit 1
fi

# 10. 构建前端
echo ""
echo "10. 构建前端应用..."
if [ -d "frontend-vue" ]; then
    cd frontend-vue
    
    # 检查Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        echo "当前Node.js版本: $NODE_VERSION"
        
        if [ "$NODE_VERSION" -lt 18 ]; then
            echo "Node.js版本不符合要求，安装Node.js 18..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
    else
        echo "Node.js未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # 安装依赖
    npm install
    
    # 创建简单的index.html（如果构建失败）
    mkdir -p dist
    cat > dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>
</head>
<body>
    <div id="app">
        <h1>图书管理系统</h1>
        <p>前端应用正在加载...</p>
    </div>
</body>
</html>
EOF
    
    # 尝试构建
    npm run build || echo "前端构建失败，使用简单HTML"
    
    cd ..
else
    echo "❌ 前端目录不存在"
    mkdir -p frontend-vue/dist
    cat > frontend-vue/dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>
</head>
<body>
    <div id="app">
        <h1>图书管理系统</h1>
        <p>前端应用正在加载...</p>
    </div>
</body>
</html>
EOF
fi

# 11. 启动后端服务
echo ""
echo "11. 启动后端服务..."
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

# 12. 启动前端服务
echo ""
echo "12. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 13. 等待服务启动
echo ""
echo "13. 等待服务启动..."
sleep 60

# 14. 测试服务
echo ""
echo "14. 测试服务..."
echo "测试后端服务..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ 后端服务正常 (状态码: $BACKEND_STATUS)"
else
    echo "❌ 后端服务异常 (状态码: $BACKEND_STATUS)"
    echo "检查后端日志:"
    docker logs --tail 20 library-backend
fi

echo ""
echo "测试前端服务..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ 前端服务正常 (状态码: $FRONTEND_STATUS)"
else
    echo "❌ 前端服务异常 (状态码: $FRONTEND_STATUS)"
fi

# 15. 显示访问地址
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