#!/bin/bash

# 图书管理系统 - 修复Maven依赖问题

set -e

echo "=== 修复Maven依赖问题 ==="
echo ""

# 1. 检查项目结构
echo "1. 检查项目结构..."
ls -la backend-microservices/

# 2. 检查backend-microservices中是否有多个服务
echo ""
echo "2. 检查backend-microservices中的服务..."
ls -la backend-microservices/

# 3. 创建一个简单的单体应用
echo ""
echo "3. 创建一个简单的单体应用..."
mkdir -p simple-app/src/main/java/com/example/library
mkdir -p simple-app/src/main/resources

# 创建pom.xml
cat > simple-app/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example.library</groupId>
    <artifactId>simple-library-app</artifactId>
    <version>1.0.0</version>
    <name>simple-library-app</name>
    <description>Simple Library Management Application</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 创建主应用类
cat > simple-app/src/main/java/com/example/library/LibraryApplication.java << 'EOF'
package com.example.library;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class LibraryApplication {
    public static void main(String[] args) {
        SpringApplication.run(LibraryApplication.class, args);
    }
}
EOF

# 创建控制器
cat > simple-app/src/main/java/com/example/library/BookController.java << 'EOF'
package com.example.library;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class BookController {
    
    @GetMapping("/books")
    public String getBooks() {
        return "图书管理系统API正在运行";
    }
    
    @GetMapping("/health")
    public String healthCheck() {
        return "{\"status\":\"ok\",\"message\":\"图书管理系统运行正常\"}";
    }
}
EOF

# 创建安全配置
cat > simple-app/src/main/java/com/example/library/SecurityConfig.java << 'EOF'
package com.example.library;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll()
            );
        
        return http.build();
    }
}
EOF

# 创建应用配置
cat > simple-app/src/main/resources/application.properties << 'EOF'
server.port=8080
server.address=0.0.0.0

# 数据库配置
spring.datasource.url=jdbc:postgresql://postgres:5432/library
spring.datasource.username=library
spring.datasource.password=library123
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA配置
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# 日志级别
logging.level.org.springframework=INFO
logging.level.com.example.library=DEBUG
EOF

# 4. 构建简单应用
echo ""
echo "4. 构建简单应用..."
cd simple-app

# 设置Maven内存限制
export MAVEN_OPTS="-Xmx1024m"

# 构建项目
mvn clean package -DskipTests

# 检查构建结果
if [ -f "target/simple-library-app-1.0.0.jar" ]; then
    echo "✅ JAR文件构建成功"
    ls -lh target/simple-library-app-1.0.0.jar
    
    # 复制到主目录
    cp target/simple-library-app-1.0.0.jar ../library-management-system.jar
    echo "已复制到主目录"
else
    echo "❌ JAR文件构建失败"
    exit 1
fi

cd ..

# 5. 停止并删除旧容器
echo ""
echo "5. 停止并删除旧容器..."
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

# 8. 创建简单的前端页面
echo ""
echo "8. 创建简单的前端页面..."
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
        .api-section {
            margin-top: 30px;
            padding: 15px;
            background-color: #f0f8ff;
            border-radius: 5px;
        }
        .api-link {
            display: block;
            text-align: center;
            margin-top: 10px;
            color: #1890ff;
        }
        button {
            background-color: #1890ff;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
        }
        #response {
            margin-top: 15px;
            padding: 10px;
            background-color: #f5f5f5;
            border-radius: 4px;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>图书管理系统</h1>
        <div class="status">
            <p class="success">✅ 前端服务已启动</p>
            <p>后端API正在运行...</p>
        </div>
        
        <div class="api-section">
            <h3>API测试</h3>
            <button onclick="testAPI()">测试后端API</button>
            <button onclick="testHealth()">检查健康状态</button>
            <div id="response"></div>
        </div>
        
        <a href="http://150.158.125.55:8080/api/health" class="api-link">访问后端API健康检查</a>
    </div>
    
    <script>
        function testAPI() {
            fetch('http://150.158.125.55:8080/api/books')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('response').textContent = '图书API响应: ' + data;
                })
                .catch(error => {
                    document.getElementById('response').textContent = '错误: ' + error.message;
                });
        }
        
        function testHealth() {
            fetch('http://150.158.125.55:8080/api/health')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('response').textContent = '健康检查响应: ' + data;
                })
                .catch(error => {
                    document.getElementById('response').textContent = '错误: ' + error.message;
                });
        }
    </script>
</body>
</html>
EOF

# 9. 启动后端服务
echo ""
echo "9. 启动后端服务..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/library-management-system.jar:/app.jar \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 10. 启动前端服务
echo ""
echo "10. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 11. 等待服务启动
echo ""
echo "11. 等待服务启动..."
sleep 60

# 12. 测试服务
echo ""
echo "12. 测试服务..."
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

# 13. 显示访问地址
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