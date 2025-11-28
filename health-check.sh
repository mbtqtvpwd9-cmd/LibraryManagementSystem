#!/bin/bash

echo "=== 项目健康检查 ==="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查函数
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 (缺失)${NC}"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 (缺失)${NC}"
        return 1
    fi
}

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✅ $1${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $1 (未安装)${NC}"
        return 1
    fi
}

echo -e "${BLUE}1. 环境检查${NC}"
check_command "java"
check_command "mvn"
check_command "node"
check_command "npm"
check_command "docker"

echo ""
echo -e "${BLUE}2. 后端项目结构检查${NC}"
check_file "pom.xml"
check_file "src/main/java/com/example/library/LibraryManagementApplication.java"
check_file "src/main/resources/application.properties"
check_dir "src/main/java/com/example/library/config"
check_dir "src/main/java/com/example/library/controller"
check_dir "src/main/java/com/example/library/service"
check_dir "src/main/java/com/example/library/model"
check_dir "src/main/java/com/example/library/repository"
check_dir "src/main/java/com/example/library/util"

echo ""
echo -e "${BLUE}3. 前端项目结构检查${NC}"
check_file "frontend-vue/package.json"
check_file "frontend-vue/vite.config.ts"
check_file "frontend-vue/tsconfig.json"
check_file "frontend-vue/index.html"
check_dir "frontend-vue/src"
check_dir "frontend-vue/src/views"
check_dir "frontend-vue/src/components"
check_dir "frontend-vue/src/stores"
check_dir "frontend-vue/src/api"
check_dir "frontend-vue/src/types"

echo ""
echo -e "${BLUE}4. 关键文件检查${NC}"
check_file "src/main/java/com/example/library/config/SecurityConfig.java"
check_file "src/main/java/com/example/library/config/JwtAuthenticationFilter.java"
check_file "src/main/java/com/example/library/util/JwtUtil.java"
check_file "src/main/java/com/example/library/controller/AuthController.java"
check_file "src/main/java/com/example/library/service/UserService.java"
check_file "src/main/java/com/example/library/model/User.java"

echo ""
echo -e "${BLUE}5. 前端关键文件检查${NC}"
check_file "frontend-vue/src/main.ts"
check_file "frontend-vue/src/App.vue"
check_file "frontend-vue/src/router/index.ts"
check_file "frontend-vue/src/views/Login.vue"
check_file "frontend-vue/src/stores/auth.ts"
check_file "frontend-vue/src/api/auth.ts"

echo ""
echo -e "${BLUE}6. 配置文件检查${NC}"
check_file "frontend-vue/.eslintrc.cjs"
check_file "frontend-vue/.prettierrc"
check_file "frontend-vue/tailwind.config.js"
check_file "frontend-vue/postcss.config.js"
check_file "frontend-vue/src/env.d.ts"

echo ""
echo -e "${BLUE}7. 构建脚本检查${NC}"
check_file "build-complete-project.sh"
check_file "deploy-simple-version.sh"
check_file "run-simple.sh"
check_file "fix-maven-dependencies.sh"

echo ""
echo -e "${BLUE}8. 文档检查${NC}"
check_file "README.md"
check_file "README-Simple.md"

# 统计检查结果
TOTAL_CHECKS=0
PASSED_CHECKS=0

# 这里应该有统计逻辑，但为了简化，我们直接显示总结

echo ""
echo -e "${BLUE}9. 项目健康总结${NC}"

# 检查Java版本
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}Java版本: $JAVA_VERSION${NC}"
fi

# 检查Node.js版本
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}Node.js版本: $NODE_VERSION${NC}"
fi

# 检查项目大小
if [ -d ".git" ]; then
    COMMITS=$(git rev-list --count HEAD)
    echo -e "${GREEN}Git提交数: $COMMITS${NC}"
fi

# 检查代码行数
echo ""
echo -e "${BLUE}10. 代码统计${NC}"

# Java代码行数
JAVA_LINES=$(find src -name "*.java" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
echo -e "${GREEN}Java代码行数: $JAVA_LINES${NC}"

# Vue/TS代码行数
VUE_LINES=$(find frontend-vue/src -name "*.vue" -o -name "*.ts" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
echo -e "${GREEN}Vue/TS代码行数: $VUE_LINES${NC}"

# 总代码行数
TOTAL_LINES=$((JAVA_LINES + VUE_LINES))
echo -e "${GREEN}总代码行数: $TOTAL_LINES${NC}"

echo ""
echo -e "${BLUE}11. 建议${NC}"

if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}⚠️  建议安装Java 17或更高版本${NC}"
fi

if ! command -v mvn &> /dev/null; then
    echo -e "${YELLOW}⚠️  建议安装Maven用于后端构建${NC}"
fi

if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  建议安装Node.js用于前端构建${NC}"
fi

if [ ! -d "frontend-vue/node_modules" ]; then
    echo -e "${YELLOW}⚠️  前端依赖未安装，请运行: cd frontend-vue && npm install${NC}"
fi

if [ ! -d "target" ]; then
    echo -e "${YELLOW}⚠️  后端未构建，请运行: ./build-complete-project.sh${NC}"
fi

echo ""
echo -e "${GREEN}健康检查完成！${NC}"
echo -e "${BLUE}运行以下命令开始构建:${NC}"
echo -e "${BLUE}  ./build-complete-project.sh${NC}"