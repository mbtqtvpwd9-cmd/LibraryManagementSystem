# 图书管理系统

一个基于Spring Boot的现代化图书管理系统，具有专业级UI/UX设计和完整的功能实现。

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
- **数据库**: H2 (开发环境), MySQL (生产环境)
- **前端**: HTML5, CSS3, JavaScript, Bootstrap 5
- **认证**: JWT (JSON Web Token)
- **容器化**: Docker, Docker Compose

## 快速开始

### 本地开发

1. **克隆项目**
```bash
git clone https://github.com/mbtqtvpwd9-cmd/LibraryManagementSystem.git
cd LibraryManagementSystem
```

2. **运行应用**
```bash
# 使用Maven
mvn spring-boot:run

# 或者使用Java
mvn clean package
java -jar target/library-management-system-1.0.0.jar
```

3. **访问应用**
- 🌟 最终界面: http://localhost:8080
- H2数据库控制台: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:librarydb`
  - 用户名: `sa`
  - 密码: `password`

### Docker部署

#### 方式1：标准部署
```bash
docker-compose up -d
```

#### 方式2：离线部署（推荐，避免网络问题）
```bash
# 1. 下载所有需要的镜像
./pull-images.sh

# 2. 一键离线部署
./offline-deploy.sh
```

#### 方式3：Ubuntu基础镜像部署（解决Maven镜像问题）
```bash
# 1. 下载基础镜像
./pull-basic-images.sh

# 2. 一键Ubuntu部署
./deploy-ubuntu.sh
```

#### 访问应用
- 应用地址: http://localhost:8080
- MySQL数据库: localhost:3306

## 腾讯云部署指南

### 1. 准备工作
- 腾讯云Ubuntu 22.04服务器
- Docker 26已安装
- Git已安装

### 2. 从GitHub部署

```bash
# 1. 登录服务器
ssh root@your-server-ip

# 2. 克隆项目
git clone https://github.com/mbtqtvpwd9-cmd/LibraryManagementSystem.git
cd LibraryManagementSystem

# 3. 一键最终部署（推荐）
./final-deploy.sh

# 4. 查看运行状态
docker-compose -f docker-compose.ubuntu.yml ps

# 5. 查看日志
docker-compose -f docker-compose.ubuntu.yml logs -f app
```

### 3. 部署方式说明

- **方式1**: `./final-deploy.sh` - 最终版本，修复所有问题
- **方式2**: `./deploy-ubuntu.sh` - Ubuntu基础镜像版本
- **方式3**: `./offline-deploy.sh` - 离线部署版本

### 3. 配置防火墙
```bash
# 允许8080端口
ufw allow 8080
ufw reload
```

### 4. 生产环境配置
- 修改 `application-prod.properties` 中的数据库连接信息
- 确保MySQL数据持久化
- 配置反向代理（Nginx）可选

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

### 用户表 (users)
- id: 主键
- username: 用户名
- password: 密码（加密）
- role: 角色（ADMIN/READER）
- email: 邮箱

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

## 开发说明

### 项目结构
```
src/main/java/com/example/library/
├── LibraryManagementApplication.java  # 主启动类
├── config/                            # 配置类
│   ├── SecurityConfig.java           # 安全配置
│   ├── JwtAuthenticationFilter.java # JWT过滤器
│   └── DataInitializer.java         # 数据初始化
├── controller/                       # 控制器
│   ├── BookController.java          # 图书控制器
│   └── AuthController.java          # 认证控制器
├── model/                            # 实体类
│   ├── Book.java                    # 图书实体
│   └── User.java                    # 用户实体
├── repository/                       # 数据访问层
│   ├── BookRepository.java          # 图书仓库
│   └── UserRepository.java          # 用户仓库
├── service/                          # 业务逻辑层
│   ├── BookService.java             # 图书服务
│   └── UserService.java             # 用户服务
└── util/                             # 工具类
    └── JwtUtil.java                 # JWT工具类
```

### 环境配置
- 开发环境: `application.properties` (H2数据库)
- 生产环境: `application-prod.properties` (MySQL数据库)

## 默认账户
- **管理员**: 用户名 `admin`, 密码 `admin123`
- **读者**: 用户名 `reader`, 密码 `reader123`

## 许可证
MIT License