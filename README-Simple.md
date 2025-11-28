# 图书馆管理系统 - 简化版

## 项目说明

这是简化版的图书馆管理系统，采用单体应用架构，包含完整的前后端功能。

## 系统要求

- Java 17 或更高版本
- Maven 3.6+ (用于完整构建)
- 或 Docker (用于容器化部署)

## 快速启动

### 方式1: 完整版本 (推荐)

如果你有Maven环境：

```bash
# 安装Maven (macOS)
brew install maven

# 运行部署脚本
./deploy-simple-version.sh
```

### 方式2: Docker版本

如果你有Docker环境：

```bash
# 运行Docker部署
./fix-login-and-security.sh
```

### 方式3: 简化版本 (仅前端)

如果没有Maven和Docker：

```bash
# 运行简化版本
./run-simple.sh
```

## 访问地址

- **前端应用**: http://localhost:8080
- **后端API**: http://localhost:3000 (完整版本)

## 默认账户

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 读者 | reader | reader123 |

## 功能特性

### 用户管理
- 用户注册和登录
- 角色权限控制 (管理员/读者)
- JWT令牌认证

### 图书管理
- 图书信息录入
- 图书查询和检索
- 图书分类管理

### 借阅管理
- 图书借阅
- 图书归还
- 借阅历史查询

### 系统功能
- 密码可见性切换
- 响应式界面设计
- 数据验证和错误处理

## API接口

### 认证接口
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123",
  "role": "ADMIN"
}
```

### 图书接口
```
GET /api/books              # 获取图书列表
POST /api/books             # 添加图书
PUT /api/books/{id}         # 更新图书
DELETE /api/books/{id}      # 删除图书
```

### 借阅接口
```
GET /api/borrowings         # 获取借阅记录
POST /api/borrowings        # 创建借阅
PUT /api/borrowings/{id}    # 归还图书
```

## 技术栈

### 后端
- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- JWT认证
- H2/MySQL数据库

### 前端
- Vue.js 3
- Vite
- Tailwind CSS
- Axios

## 开发环境设置

### 后端开发
```bash
# 编译项目
mvn clean compile

# 运行测试
mvn test

# 打包项目
mvn package

# 运行应用
java -jar target/library-management-system.jar
```

### 前端开发
```bash
cd frontend-vue

# 安装依赖
npm install

# 开发模式
npm run dev

# 构建生产版本
npm run build
```

## 故障排除

### Maven编译错误
```bash
# 清理Maven缓存
mvn clean

# 强制更新依赖
mvn install -U

# 跳过测试构建
mvn package -DskipTests
```

### 端口冲突
- 后端默认端口: 8080
- 前端默认端口: 3000
- 如有冲突，请修改配置文件

### 数据库连接
- 开发环境使用H2内存数据库
- 生产环境可配置MySQL
- 数据库配置在 `application.properties`

## 项目结构

```
├── src/main/java/com/example/library/
│   ├── config/          # 安全配置
│   ├── controller/      # 控制器
│   ├── model/          # 实体类
│   ├── repository/     # 数据访问层
│   └── service/        # 业务逻辑层
├── frontend-vue/       # 前端Vue项目
├── pom.xml            # Maven配置
└── docker-compose.yml # Docker配置
```

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License