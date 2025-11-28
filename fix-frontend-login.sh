#!/bin/bash

# 修复前端登录和Vue构建问题的脚本

echo "=== 开始修复前端登录和Vue构建问题 ==="

# 1. 进入前端目录
echo "1. 进入前端目录..."
cd frontend-vue

# 2. 安装依赖
echo "2. 安装依赖..."
npm install

# 3. 安装额外依赖（确保所有必要的依赖都已安装）
echo "3. 安装额外依赖..."
npm install --save js-cookie @types/js-cookie

# 4. 创建vite.config.ts的备份
echo "4. 备份现有配置..."
cp vite.config.ts vite.config.ts.bak

# 5. 更新vite.config.ts以确保正确配置
echo "5. 更新Vite配置..."
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src')
    }
  },
  server: {
    host: '0.0.0.0',
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    // 添加以下配置以避免构建问题
    chunkSizeWarningLimit: 1000,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            return 'vendor'
          }
        }
      }
    }
  }
})
EOF

# 6. 更新tsconfig.json
echo "6. 更新TypeScript配置..."
cat > tsconfig.json << 'EOF'
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "include": ["env.d.ts", "src/**/*", "src/**/*.vue"],
  "exclude": ["src/**/__tests__/*"],
  "compilerOptions": {
    "composite": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },
    "types": ["node"]
  }
}
EOF

# 7. 构建前端
echo "7. 构建前端..."
npm run build

# 8. 检查构建结果
echo "8. 检查构建结果..."
if [ -d "dist" ] && [ -f "dist/index.html" ]; then
    echo "前端构建成功!"
    ls -la dist/
else
    echo "前端构建失败，请检查错误信息"
    exit 1
fi

# 9. 返回项目根目录
echo "9. 返回项目根目录..."
cd ..

# 10. 复制构建结果到静态资源目录
echo "10. 复制构建结果..."
rm -rf src/main/resources/static/*
cp -r frontend-vue/dist/* src/main/resources/static/

# 11. 重新构建JAR包
echo "11. 重新构建JAR包..."
mvn clean package -DskipTests

echo ""
echo "=== 修复完成 ==="
echo ""
echo "前端已构建并复制到后端静态资源目录"
echo "JAR包已重新构建，可以使用以下命令启动："
echo "docker run -p 8080:8080 -v \$(pwd)/target/library-management-system.jar:/app.jar openjdk:17-jdk-slim java -jar /app.jar"