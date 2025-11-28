#!/bin/bash

echo "=== 运行简化版图书馆管理系统 ==="

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java，请先安装Java 17或更高版本"
    echo "下载地址: https://adoptium.net/"
    exit 1
fi

echo "当前Java版本:"
java -version

echo ""
echo "由于没有Maven环境，我们需要手动编译项目..."
echo ""

# 创建临时编译目录
mkdir -p temp-build/classes

echo "1. 编译Java源文件..."
find src/main/java -name "*.java" > temp-build/sources.txt

# 使用javac编译
javac -d temp-build/classes \
  -cp "$(find ~/.m2/repository -name "*.jar" 2>/dev/null | tr '\n' ':' | sed 's/:$//')" \
  @temp-build/sources.txt 2>/dev/null || {
  echo "编译失败: 缺少依赖库"
  echo ""
  echo "解决方案:"
  echo "1. 安装Maven: brew install maven"
  echo "2. 或者使用预构建的Docker镜像"
  echo "3. 或者下载依赖JAR文件到lib目录"
  echo ""
  echo "临时解决方案 - 使用H2内存数据库:"
  
  # 创建最小化的运行版本
  cat > temp-build/SimpleLibraryApp.java << 'EOF'
import java.io.*;
import java.net.*;
import java.util.*;

public class SimpleLibraryApp {
    public static void main(String[] args) throws IOException {
        System.out.println("=== 图书馆管理系统 ===");
        System.out.println("由于缺少Maven依赖，无法启动完整版本");
        System.out.println("");
        System.out.println("请安装Maven后运行:");
        System.out.println("  brew install maven");
        System.out.println("  ./deploy-simple-version.sh");
        System.out.println("");
        System.out.println("或者使用Docker版本:");
        System.out.println("  ./fix-login-and-security.sh");
        System.out.println("");
        
        // 启动简单的HTTP服务器提供静态文件
        if (new File("frontend-vue/dist").exists()) {
            System.out.println("启动前端静态文件服务器...");
            startSimpleServer();
        }
    }
    
    private static void startSimpleServer() throws IOException {
        ServerSocket serverSocket = new ServerSocket(8080);
        System.out.println("前端服务已启动: http://localhost:8080");
        System.out.println("按 Ctrl+C 停止服务");
        
        while (true) {
            try {
                Socket client = serverSocket.accept();
                new Thread(() -> handleRequest(client)).start();
            } catch (IOException e) {
                break;
            }
        }
    }
    
    private static void handleRequest(Socket client) {
        try (BufferedReader in = new BufferedReader(new InputStreamReader(client.getInputStream()));
             PrintWriter out = new PrintWriter(client.getOutputStream());
             BufferedOutputStream dataOut = new BufferedOutputStream(client.getOutputStream())) {
            
            String request = in.readLine();
            if (request == null) return;
            
            String[] parts = request.split(" ");
            if (parts.length < 2) return;
            
            String method = parts[0];
            String path = parts[1];
            
            if (path.equals("/")) path = "/index.html";
            
            File file = new File("frontend-vue/dist" + path);
            if (file.exists() && file.isFile()) {
                byte[] fileData = Files.readAllBytes(file.toPath());
                String contentType = getContentType(path);
                
                out.println("HTTP/1.1 200 OK");
                out.println("Content-Type: " + contentType);
                out.println("Content-Length: " + fileData.length);
                out.println();
                out.flush();
                
                dataOut.write(fileData);
                dataOut.flush();
            } else {
                out.println("HTTP/1.1 404 Not Found");
                out.println("Content-Type: text/plain");
                out.println();
                out.println("404 - File Not Found");
                out.flush();
            }
        } catch (Exception e) {
            // 忽略连接错误
        } finally {
            try { client.close(); } catch (IOException e) {}
        }
    }
    
    private static String getContentType(String path) {
        if (path.endsWith(".html")) return "text/html";
        if (path.endsWith(".css")) return "text/css";
        if (path.endsWith(".js")) return "application/javascript";
        if (path.endsWith(".json")) return "application/json";
        return "text/plain";
    }
}
EOF

echo "2. 编译简单版本..."
javac -d temp-build/classes temp-build/SimpleLibraryApp.java

echo "3. 运行应用..."
cd temp-build/classes
java SimpleLibraryApp
}

# 清理临时文件
rm -rf temp-build