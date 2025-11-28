#!/bin/bash

# 直接从微服务版本构建可运行JAR
# 适用于只有微服务版本的情况

echo "=== 从微服务版本构建可运行应用 ==="

# 1. 检查微服务模块
echo "1. 检查微服务模块..."
if [ ! -d "backend-microservices/gateway-service" ]; then
    echo "✗ 找不到gateway-service模块"
    exit 1
fi

if [ ! -d "backend-microservices/common-service" ]; then
    echo "✗ 找不到common-service模块"
    exit 1
fi

# 2. 创建临时构建目录
echo "2. 创建构建环境..."
rm -rf /tmp/library-build
mkdir -p /tmp/library-build

# 3. 复制并合并源码
echo "3. 合并源码..."
cp -r backend-microservices/gateway-service/src /tmp/library-build/
cp -r backend-microservices/common-service/src/main/java/com/example/library/common /tmp/library-build/src/main/java/com/example/library/

# 4. 创建简化的pom.xml
echo "4. 创建构建配置..."
cat > /tmp/library-build/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>library-management-system</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

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
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.33</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.example.library.GatewayServiceApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 5. 创建应用配置
echo "5. 创建应用配置..."
mkdir -p /tmp/library-build/src/main/resources
cat > /tmp/library-build/src/main/resources/application.yml << 'EOF'
server:
  port: 8080

spring:
  application:
    name: library-management-system
  
  datasource:
    url: jdbc:mysql://db:3306/library_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: root
    password: rootpassword
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false

jwt:
  secret: mySecretKey12345
  expiration: 86400000

logging:
  level:
    com.example.library: INFO
EOF

# 6. 构建应用
echo "6. 构建应用..."
cd /tmp/library-build
mvn clean package -DskipTests -q

# 7. 复制JAR回原项目
echo "7. 复制构建结果..."
mkdir -p ~/LibraryManagementSystem/target
cp target/library-management-system-1.0.0.jar ~/LibraryManagementSystem/target/

cd ~/LibraryManagementSystem

echo "✅ 构建完成！"
echo "JAR文件: target/library-management-system-1.0.0.jar"
echo ""
echo "现在启动服务:"
echo "docker-compose -f docker-compose.tencent.yml up -d"