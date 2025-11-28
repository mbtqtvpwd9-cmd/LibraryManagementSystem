# 图书馆管理系统 - 项目文档

## 📋 项目概述

这是一个基于Spring Boot + Vue 3的现代化图书馆管理系统，采用前后端分离架构，支持完整的图书管理、用户管理和借阅管理功能。

## 🏗️ 技术架构

### 后端技术栈
- **框架**: Spring Boot 3.2.0
- **安全**: Spring Security + JWT认证
- **数据库**: H2 (开发) / MySQL (生产)
- **ORM**: Spring Data JPA
- **构建工具**: Maven
- **Java版本**: 17+

### 前端技术栈
- **框架**: Vue 3 + TypeScript
- **UI组件**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **构建工具**: Vite
- **样式**: Tailwind CSS
- **HTTP客户端**: Axios

## 📁 项目结构

```
LibraryManagementSystem/
├── src/main/java/com/example/library/          # 后端源码
│   ├── config/                                # 配置类
│   │   ├── SecurityConfig.java               # 安全配置
│   │   ├── JwtAuthenticationFilter.java      # JWT过滤器
│   │   └── DataInitializer.java              # 数据初始化
│   ├── controller/                            # 控制器
│   │   ├── AuthController.java               # 认证控制器
│   │   ├── BookController.java               # 图书控制器
│   │   └── BorrowingController.java          # 借阅控制器
│   ├── service/                               # 业务逻辑
│   │   ├── UserService.java                  # 用户服务
│   │   ├── BookService.java                  # 图书服务
│   │   └── BorrowingService.java             # 借阅服务
│   ├── model/                                 # 实体类
│   │   ├── User.java                         # 用户实体
│   │   ├── Book.java                         # 图书实体
│   │   └── Borrowing.java                    # 借阅实体
│   ├── repository/                            # 数据访问层
│   └── util/                                  # 工具类
│       └── JwtUtil.java                       # JWT工具
├── frontend-vue/                              # 前端源码
│   ├── src/
│   │   ├── views/                            # 页面组件
│   │   │   ├── Login.vue                     # 登录页
│   │   │   ├── Dashboard.vue                 # 仪表盘
│   │   │   ├── Books.vue                     # 图书管理
│   │   │   ├── Borrowings.vue                # 借阅管理
│   │   │   ├── Users.vue                     # 用户管理
│   │   │   └── Reports.vue                   # 统计报表
│   │   ├── stores/                           # 状态管理
│   │   │   ├── auth.ts                       # 认证状态
│   │   │   └── book.ts                       # 图书状态
│   │   ├── api/                              # API接口
│   │   ├── types/                            # 类型定义
│   │   ├── router/                           # 路由配置
│   │   └── assets/                           # 静态资源
│   ├── package.json                          # 依赖配置
│   ├── vite.config.ts                        # Vite配置
│   └── tailwind.config.js                    # Tailwind配置
├── backend-microservices/                     # 微服务版本
│   ├── common-service/                        # 公共模块
│   ├── gateway-service/                       # 网关服务
│   ├── user-service/                          # 用户服务
│   ├── book-service/                          # 图书服务
│   └── borrow-service/                        # 借阅服务
├── scripts/                                   # 构建脚本
│   ├── build-complete-project.sh             # 完整构建
│   ├── deploy-simple-version.sh              # 简化部署
│   ├── run-simple.sh                         # 简单运行
│   ├── health-check.sh                        # 健康检查
│   └── fix-maven-dependencies.sh             # Maven修复
└── docs/                                      # 文档
    ├── README.md                              # 项目说明
    ├── README-Simple.md                       # 简化版说明
    └── PROJECT-DOCUMENTATION.md              # 项目文档
```

## 🚀 快速开始

### 环境要求
- Java 17+
- Maven 3.6+
- Node.js 16+
- npm 8+

### 一键构建
```bash
# 运行健康检查
./health-check.sh

# 完整构建项目
./build-complete-project.sh

# 简单运行
./run-simple.sh
```

### 分步构建

#### 后端构建
```bash
# 编译
mvn clean compile

# 测试
mvn test

# 打包
mvn package

# 运行
java -jar target/library-management-system-1.0.0.jar
```

#### 前端构建
```bash
cd frontend-vue

# 安装依赖
npm install

# 开发模式
npm run dev

# 构建
npm run build

# 预览
npm run preview
```

## 🔐 认证与授权

### JWT认证流程
1. 用户登录提交用户名、密码和角色
2. 后端验证凭据并生成JWT令牌
3. 前端保存令牌并在请求头中携带
4. 后端过滤器验证令牌有效性

### 角色权限
- **ADMIN**: 管理员，拥有所有权限
- **READER**: 读者，只能查看和借阅图书

### 默认账户
- 管理员: `admin / admin123`
- 读者: `reader / reader123`

## 📚 功能特性

### 用户管理
- ✅ 用户注册和登录
- ✅ 角色权限控制
- ✅ 密码加密存储
- ✅ JWT令牌认证
- ✅ 登录状态保持

### 图书管理
- ✅ 图书信息录入
- ✅ 图书查询和检索
- ✅ 图书分类管理
- ✅ 库存管理
- ✅ 图书信息修改和删除

### 借阅管理
- ✅ 图书借阅
- ✅ 图书归还
- ✅ 借阅历史查询
- ✅ 借阅统计
- ✅ 逾期管理

### 系统功能
- ✅ 响应式设计
- ✅ 密码可见性切换
- ✅ 数据验证
- ✅ 错误处理
- ✅ 统计报表
- ✅ 数据导出

## 🔌 API接口

### 认证接口
```
POST /api/auth/login          # 用户登录
POST /api/auth/register       # 用户注册
GET  /api/auth/me            # 获取当前用户
POST /api/auth/logout        # 用户登出
```

### 图书接口
```
GET    /api/books            # 获取图书列表
POST   /api/books            # 添加图书
GET    /api/books/{id}       # 获取图书详情
PUT    /api/books/{id}       # 更新图书
DELETE /api/books/{id}       # 删除图书
```

### 借阅接口
```
GET    /api/borrowings       # 获取借阅记录
POST   /api/borrowings       # 创建借阅
PUT    /api/borrowings/{id}  # 归还图书
GET    /api/borrowings/my    # 我的借阅
```

## 🗄️ 数据库设计

### 用户表 (users)
- id: 主键
- username: 用户名
- password: 密码
- role: 角色
- email: 邮箱

### 图书表 (books)
- id: 主键
- isbn: ISBN号
- title: 书名
- author: 作者
- publisher: 出版社
- publish_year: 出版年份
- price: 价格
- stock_quantity: 库存数量
- description: 描述

### 借阅表 (borrowings)
- id: 主键
- user_id: 用户ID
- book_id: 图书ID
- borrow_date: 借阅日期
- due_date: 应还日期
- return_date: 实际归还日期
- status: 状态

## 🛠️ 开发指南

### 代码规范
- 后端遵循阿里巴巴Java开发规范
- 前端使用ESLint + Prettier
- 提交信息遵循Conventional Commits

### 测试策略
- 单元测试: JUnit + Mockito
- 集成测试: Spring Boot Test
- 前端测试: Vue Test Utils

### 部署方案
- 开发环境: 直接运行JAR
- 生产环境: Docker容器化
- 云部署: 支持各大云平台

## 📈 性能优化

### 后端优化
- 数据库索引优化
- 查询缓存
- 分页查询
- 连接池配置

### 前端优化
- 路由懒加载
- 组件按需引入
- 图片压缩
- 构建优化

## 🔧 配置说明

### 后端配置 (application.properties)
```properties
# 服务器配置
server.port=8080

# 数据库配置
spring.datasource.url=jdbc:h2:mem:librarydb
spring.jpa.hibernate.ddl-auto=create-drop

# JWT配置
jwt.secret=libraryManagementSystemSecretKey2024
jwt.expiration=86400000

# 日志配置
logging.level.com.example.library=DEBUG
```

### 前端配置 (vite.config.ts)
```typescript
export default defineConfig({
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
```

## 🐛 故障排除

### 常见问题

#### 1. Maven依赖冲突
```bash
# 清理并重新构建
mvn clean install -U

# 跳过测试
mvn package -DskipTests
```

#### 2. 前端构建失败
```bash
# 清理缓存
npm cache clean --force

# 重新安装依赖
rm -rf node_modules package-lock.json
npm install
```

#### 3. JWT令牌过期
- 检查JWT配置中的过期时间
- 前端实现令牌自动刷新

#### 4. 跨域问题
- 检查Spring Security的CORS配置
- 确认前端代理配置正确

## 📝 更新日志

### v1.0.0 (2024-11-28)
- ✅ 完成基础架构搭建
- ✅ 实现用户认证系统
- ✅ 完成图书管理功能
- ✅ 实现借阅管理功能
- ✅ 添加前端响应式界面
- ✅ 完善项目文档

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 项目地址: https://github.com/mbtqtvpwd9-cmd/LibraryManagementSystem
- 问题反馈: Issues

---

**注意**: 这是一个学习和演示项目，生产环境使用请进行充分测试和安全评估。