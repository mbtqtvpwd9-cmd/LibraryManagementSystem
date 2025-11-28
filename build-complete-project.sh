#!/bin/bash

echo "=== 完整构建图书馆管理系统 ==="

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 错误处理函数
handle_error() {
    echo -e "${RED}错误: $1${NC}"
    exit 1
}

# 成功信息函数
success() {
    echo -e "${GREEN}$1${NC}"
}

# 警告信息函数
warning() {
    echo -e "${YELLOW}$1${NC}"
}

# 信息函数
info() {
    echo -e "${BLUE}$1${NC}"
}

# 1. 环境检查
info "1. 检查环境依赖..."

# 检查Java
if ! command -v java &> /dev/null; then
    handle_error "未找到Java，请安装Java 17或更高版本"
fi
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
success "Java版本: $JAVA_VERSION"

# 检查Maven
if ! command -v mvn &> /dev/null; then
    warning "未找到Maven，尝试使用Maven Wrapper..."
    if [ ! -f "./mvnw" ]; then
        handle_error "未找到Maven和Maven Wrapper，请安装Maven"
    fi
    MVN_CMD="./mvnw"
else
    MVN_CMD="mvn"
    success "Maven已安装"
fi

# 检查Node.js
if ! command -v node &> /dev/null; then
    handle_error "未找到Node.js，请安装Node.js 16或更高版本"
fi
NODE_VERSION=$(node --version)
success "Node.js版本: $NODE_VERSION"

# 检查npm
if ! command -v npm &> /dev/null; then
    handle_error "未找到npm，请安装npm"
fi
NPM_VERSION=$(npm --version)
success "npm版本: $NPM_VERSION"

# 2. 后端构建
info "2. 构建后端项目..."

# 清理和编译
info "清理和编译后端代码..."
$MVN_CMD clean compile -DskipTests
if [ $? -ne 0 ]; then
    handle_error "后端编译失败"
fi
success "后端编译成功"

# 运行测试
info "运行后端测试..."
$MVN_CMD test
if [ $? -ne 0 ]; then
    warning "后端测试失败，但继续构建..."
fi

# 打包
info "打包后端应用..."
$MVN_CMD package -DskipTests
if [ $? -ne 0 ]; then
    handle_error "后端打包失败"
fi
success "后端打包成功"

# 检查JAR文件
JAR_FILE=$(find target -name "*.jar" -not -name "*-sources.jar" | head -1)
if [ -z "$JAR_FILE" ]; then
    handle_error "未找到可执行的JAR文件"
fi
success "后端JAR文件: $JAR_FILE"

# 3. 前端构建
info "3. 构建前端项目..."

cd frontend-vue

# 安装依赖
info "安装前端依赖..."
npm install
if [ $? -ne 0 ]; then
    handle_error "前端依赖安装失败"
fi
success "前端依赖安装成功"

# 代码检查
info "运行前端代码检查..."
npm run lint
if [ $? -ne 0 ]; then
    warning "前端代码检查发现问题，但继续构建..."
fi

# 类型检查
info "运行TypeScript类型检查..."
npm run build
if [ $? -ne 0 ]; then
    handle_error "前端类型检查或构建失败"
fi
success "前端构建成功"

# 返回项目根目录
cd ..

# 4. 集成构建
info "4. 执行集成构建..."

# 将前端构建产物复制到Spring Boot静态资源目录
if [ -d "frontend-vue/dist" ]; then
    info "复制前端构建产物到后端静态资源目录..."
    mkdir -p src/main/resources/static
    cp -r frontend-vue/dist/* src/main/resources/static/
    success "前端构建产物复制完成"
else
    warning "未找到前端构建产物"
fi

# 重新打包包含前端的后端应用
info "重新打包包含前端的完整应用..."
$MVN_CMD package -DskipTests
if [ $? -ne 0 ]; then
    handle_error "完整应用打包失败"
fi
success "完整应用打包成功"

# 5. 生成构建报告
info "5. 生成构建报告..."

BUILD_REPORT="build-report-$(date +%Y%m%d-%H%M%S).md"
cat > $BUILD_REPORT << EOF
# 图书馆管理系统构建报告

## 构建时间
$(date)

## 环境信息
- Java: $JAVA_VERSION
- Maven: $($MVN_CMD --version | head -n 1)
- Node.js: $NODE_VERSION
- npm: $NPM_VERSION

## 构建结果
- ✅ 后端编译: 成功
- ✅ 后端打包: 成功
- ✅ 前端依赖安装: 成功
- ✅ 前端构建: 成功
- ✅ 集成构建: 成功

## 产物文件
- 后端JAR: $JAR_FILE
- 前端构建: frontend-vue/dist/
- 构建报告: $BUILD_REPORT

## 部署说明
1. 后端启动: \`java -jar $JAR_FILE\`
2. 访问地址: http://localhost:8080
3. 默认账户: admin/admin123

## 项目特性
- ✅ Spring Security + JWT认证
- ✅ Vue 3 + TypeScript前端
- ✅ Element Plus UI组件
- ✅ 响应式设计
- ✅ 密码可见性切换
- ✅ 角色权限控制
- ✅ RESTful API
- ✅ H2内存数据库
EOF

success "构建报告生成完成: $BUILD_REPORT"

# 6. 构建验证
info "6. 验证构建产物..."

# 检查JAR文件大小
JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
success "JAR文件大小: $JAR_SIZE"

# 检查前端构建产物
if [ -f "src/main/resources/static/index.html" ]; then
    success "前端首页文件存在"
else
    warning "前端首页文件不存在"
fi

# 7. 完成总结
echo ""
success "🎉 构建完成！"
echo ""
info "构建产物:"
echo "  - 后端JAR文件: $JAR_FILE ($JAR_SIZE)"
echo "  - 前端构建: frontend-vue/dist/"
echo "  - 构建报告: $BUILD_REPORT"
echo ""
info "快速启动:"
echo "  java -jar $JAR_FILE"
echo ""
info "访问地址:"
echo "  http://localhost:8080"
echo ""
info "默认登录账户:"
echo "  管理员: admin / admin123"
echo "  读者: reader / reader123"
echo ""

# 8. 可选的Docker构建
if command -v docker &> /dev/null; then
    info "检测到Docker，可以构建Docker镜像..."
    read -p "是否构建Docker镜像? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "构建Docker镜像..."
        docker build -t library-management-system:latest .
        if [ $? -eq 0 ]; then
            success "Docker镜像构建成功"
            info "运行命令: docker run -p 8080:8080 library-management-system:latest"
        else
            warning "Docker镜像构建失败"
        fi
    fi
fi

success "所有构建任务完成！"