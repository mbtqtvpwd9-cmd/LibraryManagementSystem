#!/bin/bash

# 为微服务版本创建可运行的单体应用
# 从微服务模块合并成单体应用

echo "=== 从微服务版本创建可运行应用 ==="

# 1. 创建临时单体应用目录
echo "1. 创建单体应用结构..."
mkdir -p /tmp/monolith-app/src/main/java/com/example/library
mkdir -p /tmp/monolith-app/src/main/resources

# 2. 复制gateway-service的代码作为基础
echo "2. 复制gateway-service代码..."
if [ -d "backend-microservices/gateway-service/src" ]; then
    cp -r backend-microservices/gateway-service/src/* /tmp/monolith-app/src/
else
    echo "✗ 找不到gateway-service源码"
    exit 1
fi

# 3. 复制common-service的代码
echo "3. 复制common-service代码..."
if [ -d "backend-microservices/common-service/src" ]; then
    cp -r backend-microservices/common-service/src/main/java/com/example/library/common /tmp/monolith-app/src/main/java/com/example/library/
fi

# 4. 创建单体应用的pom.xml
echo "4. 创建单体应用pom.xml..."
cat > /tmp/monolith-app/pom.xml << 'EOF'
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
    <name>Library Management System</name>
    <description>A simple library management system</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Web Starter -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- H2 Database -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- MySQL Driver -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.33</version>
            <scope>runtime</scope>
        </dependency>

        <!-- Spring Boot Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!-- Spring Boot Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- JWT -->
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

        <!-- Spring Boot Test -->
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

# 5. 创建应用配置
echo "5. 创建应用配置..."
cat > /tmp/monolith-app/src/main/resources/application.yml << 'EOF'
server:
  port: 8080

spring:
  application:
    name: library-management-system
  
  datasource:
    url: jdbc:mysql://localhost:3306/library_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: root
    password: rootpassword
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
  
  h2:
    console:
      enabled: true

# JWT配置
jwt:
  secret: mySecretKey
  expiration: 86400000

logging:
  level:
    com.example.library: DEBUG
    org.springframework.security: DEBUG
EOF

# 6. 构建单体应用
echo "6. 构建单体应用..."
cd /tmp/monolith-app
mvn clean package -DskipTests -q

# 7. 复制JAR文件回原项目
echo "7. 复制构建结果..."
mkdir -p ~/LibraryManagementSystem/target
cp target/library-management-system-1.0.0.jar ~/LibraryManagementSystem/target/

# 8. 返回原目录
cd ~/LibraryManagementSystem

echo "✅ 单体应用构建完成！"
echo "JAR文件位置: ~/LibraryManagementSystem/target/library-management-system-1.0.0.jar"
echo ""
echo "现在可以运行: docker-compose -f docker-compose.tencent.yml up -d"