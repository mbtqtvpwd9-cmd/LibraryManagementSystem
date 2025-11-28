# 图书管理系统

一个基于Spring Boot的现代化图书管理系统，具有专业级UI/UX设计和完整的功能实现，支持Docker容器化部署。

## 功能特性

### 🎯 核心功能
- ✅ 用户认证和授权（管理员和读者角色）
- ✅ 图书信息管理（完整CRUD操作）
- ✅ 图书编辑功能（支持分类、语言、位置等）
- ✅ 高级搜索和筛选（多条件组合搜索）
- ✅ 借阅管理系统（借书、还书、续借）
- ✅ 统计报表仪表盘
- ✅ 分页查询和排序
- ✅ RESTful API设计
- ✅ JWT令牌认证
- ✅ 数据验证和错误处理

### 🎨 界面特性
- ✅ 现代化响应式设计
- ✅ 网格和列表双视图模式
- ✅ 美观的卡片式布局
- ✅ 浮动操作按钮
- ✅ 模态框编辑界面
- ✅ 实时搜索和筛选
- ✅ 统计数据可视化

### 📚 图书管理
- ✅ 图书基本信息（ISBN、书名、作者、出版社）
- ✅ 扩展信息（分类、语言、存放位置）
- ✅ 库存管理（总数量、已借出数量）
- ✅ 价格和出版信息
- ✅ 封面图片支持
- ✅ 图书状态管理

### 🔄 借阅管理
- ✅ 图书借阅申请
- ✅ 借阅期限管理
- ✅ 图书归还处理
- ✅ 续借功能
- ✅ 逾期提醒
- ✅ 借阅历史记录

### 👥 用户角色
- **管理员 (admin/admin123)**: 完整管理权限
- **读者 (reader/reader123)**: 查询和借阅权限

### 🌐 技术栈
- **后端**: Java 17, Spring Boot 3.2.0, Spring Security, Spring Data JPA
- **前端**: Vue 3, Vite, TypeScript, Element Plus
- **数据库**: PostgreSQL, Redis
- **认证**: JWT (JSON Web Token)
- **容器化**: Docker

## 快速开始

### 本地开发

1. **克隆项目**
```bash
git clone https://github.com/mbtqtvpwd9-cmd/LibraryManagementSystem.git
cd LibraryManagementSystem
git checkout advanced-tech-stack
```

2. **环境要求**
- Java 17+
- Node.js 18+
- Maven 3.6+
- Docker & Docker Compose

3. **运行应用**
```bash
# 构建后端
cd backend-microservices
mvn clean package -DskipTests
cd ..

# 构建前端
cd frontend-vue
npm install
npm run build
cd ..

# 启动所有服务
docker-compose up -d
```

4. **访问应用**
- 🌟 前端应用: http://localhost:3000
- 📊 API网关: http://localhost:8080

## 腾讯云部署指南

### 1. 准备工作
- 腾讯云Ubuntu 22.04服务器
- 服务器IP: 150.158.125.55
- 开放端口: 3000 (前端), 8080 (后端API)

### 2. 快速部署（推荐）

```bash
# 1. 登录服务器
ssh root@150.158.125.55

# 2. 克隆项目
git clone https://github.com/mbtqtvpwd9-cmd/LibraryManagementSystem.git
cd LibraryManagementSystem
git checkout advanced-tech-stack

# 3. 一键部署
./java-fix-deploy.sh

# 4. 部署检查
./check-deployment.sh
```

### 3. 部署脚本说明

| 脚本名称 | 用途 |
|---------|------|
| `java-fix-deploy.sh` | 完整部署脚本（推荐首次使用）|
| `manual-deploy.sh` | 手动更新部署脚本 |
| `check-deployment.sh` | 检查部署状态 |
| `troubleshoot-network.sh` | 网络问题排查 |
| `fix-nginx-403-v2.sh` | 修复Nginx 403错误 |
| `fix-vue-build.sh` | 修复Vue构建问题 |

### 4. 常见问题解决

#### Java版本问题
```bash
./java-fix-deploy.sh  # 自动安装Java 17
```

#### 前端构建问题
```bash
./fix-vue-build.sh  # 修复TypeScript编译错误
```

#### 网络访问问题
```bash
./troubleshoot-network.sh  # 排查网络问题
```

#### Nginx 403错误
```bash
./fix-nginx-403-v2.sh  # 修复权限和配置问题
```

### 5. 手动部署步骤

如果自动脚本失败，可执行以下手动命令：

```bash
# 1. 停止旧容器
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 2. 创建网络
docker network create library-network 2>/dev/null || true

# 3. 启动基础服务
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

# 4. 等待基础服务启动
sleep 30

# 5. 构建后端
mvn clean package -DskipTests

# 6. 构建前端
cd frontend-vue
npm install
npm run build
cd ..

# 7. 启动应用服务
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/target/library-management-system.jar:/app.jar \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 8. 检查状态
sleep 30
docker ps
```

## 微服务架构

### 服务组件
- **API网关** (8080): 统一入口，路由和负载均衡
- **图书服务** (8081): 图书信息管理
- **用户服务** (8082): 用户认证和管理
- **借阅服务** (8083): 图书借阅管理
- **前端应用** (3000): Vue 3单页应用
- **数据库**: PostgreSQL + Redis

## API文档

### 认证接口
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/register` - 用户注册
- `GET /api/auth/me` - 获取当前用户信息
- `POST /api/auth/logout` - 用户退出

### 图书接口
- `GET /api/books` - 获取图书列表（分页）
- `GET /api/books/{id}` - 获取单本图书
- `GET /api/books/search` - 搜索图书
- `POST /api/books` - 添加图书（管理员）
- `PUT /api/books/{id}` - 更新图书（管理员）
- `DELETE /api/books/{id}` - 删除图书（管理员）

## 数据库结构

### 图书表 (books)
- id: 主键
- isbn: ISBN号（唯一）
- title: 书名
- author: 作者
- publisher: 出版社
- publishYear: 出版年份
- price: 价格
- stockQuantity: 库存数量
- description: 描述

### 用户表 (users)
- id: 主键
- username: 用户名
- password: 密码（加密）
- role: 角色（ADMIN/READER）
- email: 邮箱

## 默认账户
- **管理员**: 用户名 `admin`, 密码 `admin123`
- **读者**: 用户名 `reader`, 密码 `reader123`

## 访问地址
- 前端应用: http://150.158.125.55:3000
- API网关: http://150.158.125.55:8080

## 许可证
MIT License