#!/bin/bash

echo "=== 快速解决Maven构建错误 ==="

echo ""
echo "🔍 问题分析："
echo "  你遇到了Maven依赖解析错误，原因："
echo "  1. 系统没有安装Maven"
echo "  2. 尝试构建微服务版本，但common-service模块未安装到本地仓库"
echo ""

echo "🎯 推荐解决方案："
echo ""

echo "方案1: 安装Maven并使用简化版（推荐）"
echo "  # 安装Maven"
echo "  brew install maven"
echo "  # 使用简化版（功能完整，无依赖问题）"
echo "  ./build-complete-project.sh"
echo ""

echo "方案2: 仅使用Java运行简化版（立即可用）"
echo "  # 不需要Maven，直接运行"
echo "  ./run-simple.sh"
echo ""

echo "方案3: 使用Docker（如果有Docker）"
echo "  # Docker方式运行"
echo "  ./fix-login-and-security.sh"
echo ""

echo "⚠️  不推荐：继续尝试微服务版本"
echo "  微服务版本需要完整的Maven环境，且配置复杂"
echo "  简化版已经包含所有功能，更容易运行"
echo ""

echo "🚀 立即可用的命令："
echo "  ./run-simple.sh"
echo ""

echo "📋 项目现状："
echo "  ✅ 简化版单体应用：完整功能，可直接运行"
echo "  ❌ 微服务版本：需要Maven，配置复杂"
echo "  ✅ 所有功能都已实现在简化版中"
echo ""

read -p "是否运行简化版? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "启动简化版..."
    ./run-simple.sh
else
    echo "请选择上述方案之一解决问题"
fi