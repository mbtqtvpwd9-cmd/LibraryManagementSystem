#!/bin/bash

# 图书管理系统 - 修复API端点

set -e

echo "=== 修复API端点 ==="
echo ""

# 1. 获取服务器IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "服务器IP: $EXTERNAL_IP"

# 2. 检查当前服务状态
echo ""
echo "1. 检查当前服务状态..."
echo "前端服务状态:"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
echo "状态码: $FRONTEND_STATUS"

echo ""
echo "后端服务状态:"
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
echo "状态码: $BACKEND_STATUS"

# 3. 创建更完善的前端页面
echo ""
echo "2. 创建更完善的前端页面..."
mkdir -p frontend-vue/dist
cat > frontend-vue/dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
            transition: transform 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
        }
        .card-header {
            background-color: #4a6bdf;
            color: white;
            font-weight: bold;
            border-radius: 10px 10px 0 0 !important;
        }
        .btn-custom {
            background-color: #4a6bdf;
            border: none;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            margin: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .btn-custom:hover {
            background-color: #3a5bcf;
        }
        .status-success {
            color: #28a745;
            font-weight: bold;
        }
        .status-error {
            color: #dc3545;
            font-weight: bold;
        }
        .api-response {
            background-color: #f1f1f1;
            border-radius: 5px;
            padding: 15px;
            margin-top: 15px;
            white-space: pre-wrap;
            max-height: 300px;
            overflow-y: auto;
        }
        .system-info {
            background-color: #e7f3ff;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header class="text-center mb-4">
            <h1 class="display-4">图书管理系统</h1>
            <p class="lead">现代化的图书信息管理平台</p>
        </header>

        <div class="system-info">
            <h3>系统状态</h3>
            <p>前端服务: <span id="frontend-status" class="status-success">运行中</span></p>
            <p>后端API: <span id="backend-status" class="status-success">运行中</span></p>
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">API测试</div>
                    <div class="card-body">
                        <h5>测试后端API接口</h5>
                        <button class="btn btn-custom" onclick="testHealth()">健康检查</button>
                        <button class="btn btn-custom" onclick="testBooks()">图书接口</button>
                        <div id="api-response" class="api-response">点击上方按钮测试API接口...</div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">系统信息</div>
                    <div class="card-body">
                        <h5>图书管理系统 v1.0</h5>
                        <p>基于Spring Boot和Vue.js构建的现代化图书管理应用</p>
                        <p>主要功能:</p>
                        <ul>
                            <li>图书信息管理</li>
                            <li>用户认证与授权</li>
                            <li>借阅管理</li>
                            <li>统计分析</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">快速链接</div>
            <div class="card-body">
                <h5>访问地址</h5>
                <p>前端应用: <a href="http://150.158.125.55:3000" target="_blank">http://150.158.125.55:3000</a></p>
                <p>后端API: <a href="http://150.158.125.55:8080" target="_blank">http://150.158.125.55:8080</a></p>
                <p>API健康检查: <a href="http://150.158.125.55:8080/api/health" target="_blank">http://150.158.125.55:8080/api/health</a></p>
            </div>
        </div>
    </div>

    <script>
        function testHealth() {
            document.getElementById('api-response').textContent = '正在测试健康检查...';
            fetch('http://150.158.125.55:8080/api/health')
                .then(response => {
                    if (!response.ok) throw new Error('响应状态: ' + response.status);
                    return response.text();
                })
                .then(data => {
                    document.getElementById('api-response').textContent = '健康检查响应:\n' + JSON.stringify(JSON.parse(data), null, 2);
                    document.getElementById('backend-status').textContent = '运行正常';
                    document.getElementById('backend-status').className = 'status-success';
                })
                .catch(error => {
                    document.getElementById('api-response').textContent = '错误: ' + error.message;
                    document.getElementById('backend-status').textContent = '连接异常';
                    document.getElementById('backend-status').className = 'status-error';
                });
        }
        
        function testBooks() {
            document.getElementById('api-response').textContent = '正在测试图书接口...';
            fetch('http://150.158.125.55:8080/api/books')
                .then(response => {
                    if (!response.ok) throw new Error('响应状态: ' + response.status);
                    return response.text();
                })
                .then(data => {
                    document.getElementById('api-response').textContent = '图书API响应:\n' + data;
                    document.getElementById('backend-status').textContent = '运行正常';
                    document.getElementById('backend-status').className = 'status-success';
                })
                .catch(error => {
                    document.getElementById('api-response').textContent = '错误: ' + error.message;
                    document.getElementById('backend-status').textContent = '连接异常';
                    document.getElementById('backend-status').className = 'status-error';
                });
        }
        
        // 页面加载时自动检查健康状态
        window.onload = function() {
            setTimeout(testHealth, 1000);
        };
    </script>
</body>
</html>
EOF

# 4. 检查是否需要更新后端API
echo ""
echo "3. 检查是否需要更新后端API..."
# 检查当前JAR文件
if [ -f "library-management-system.jar" ]; then
    echo "✅ JAR文件存在"
    # 尝试检查API响应
    HEALTH_CHECK=$(curl -s http://localhost:8080/api/health 2>/dev/null || echo "")
    if [[ $HEALTH_CHECK == *"ok"* ]]; then
        echo "✅ API健康检查正常"
        echo "响应内容: $HEALTH_CHECK"
    else
        echo "❌ API健康检查异常"
        echo "响应内容: $HEALTH_CHECK"
        
        # 检查是否需要重新构建
        echo "5. 重新构建后端应用..."
        if [ -d "simple-app" ]; then
            cd simple-app
            export MAVEN_OPTS="-Xmx1024m"
            mvn clean package -DskipTests
            
            if [ -f "target/simple-library-app-1.0.0.jar" ]; then
                echo "✅ 重新构建成功"
                cp target/simple-library-app-1.0.0.jar ../library-management-system.jar
                
                # 停止并重启后端容器
                cd ..
                docker stop library-backend
                docker rm library-backend
                
                docker run -d --name library-backend \
                  --network library-network \
                  -p 8080:8080 \
                  -v $(pwd)/library-management-system.jar:/app.jar \
                  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
                  -e SPRING_DATASOURCE_USERNAME=library \
                  -e SPRING_DATASOURCE_PASSWORD=library123 \
                  openjdk:17-jdk-slim \
                  java -jar -Dserver.address=0.0.0.0 /app.jar
                
                echo "等待后端重启..."
                sleep 30
            else
                echo "❌ 重新构建失败"
                exit 1
            fi
        else
            echo "❌ simple-app目录不存在"
        fi
    fi
else
    echo "❌ JAR文件不存在"
fi

# 6. 重启前端容器（使用新页面）
echo ""
echo "6. 重启前端容器..."
docker stop library-frontend
docker rm library-frontend

docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 7. 等待服务启动
echo ""
echo "7. 等待服务启动..."
sleep 15

# 8. 测试服务
echo ""
echo "8. 测试服务..."
echo "测试前端服务..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
echo "状态码: $FRONTEND_STATUS"

echo ""
echo "测试后端服务..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
echo "状态码: $BACKEND_STATUS"

echo ""
echo "测试API健康检查..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/health 2>/dev/null || echo "000")
echo "状态码: $HEALTH_STATUS"

if [ "$HEALTH_STATUS" = "200" ]; then
    echo "✅ API健康检查正常"
else
    echo "❌ API健康检查异常"
fi

# 9. 显示访问地址
echo ""
echo "=== 修复完成 ==="
echo ""
echo "访问地址："
echo "前端应用: http://$EXTERNAL_IP:3000"
echo "后端API: http://$EXTERNAL_IP:8080"
echo ""
echo "API端点："
echo "健康检查: http://$EXTERNAL_IP:8080/api/health"
echo "图书接口: http://$EXTERNAL_IP:8080/api/books"
echo ""
echo "容器状态："
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"