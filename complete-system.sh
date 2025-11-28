#!/bin/bash

# 图书管理系统 - 完整功能部署

set -e

echo "=== 完整功能部署 ==="
echo ""

# 1. 获取服务器IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "服务器IP: $EXTERNAL_IP"

# 2. 停止旧容器
echo ""
echo "1. 停止旧容器..."
docker stop library-backend library-frontend 2>/dev/null || true
docker rm library-backend library-frontend 2>/dev/null || true

# 3. 创建更完整的后端应用
echo ""
echo "2. 创建更完整的后端应用..."
mkdir -p complete-app/src/main/java/com/example/library/model
mkdir -p complete-app/src/main/java/com/example/library/controller
mkdir -p complete-app/src/main/java/com/example/library/repository
mkdir -p complete-app/src/main/java/com/example/library/service
mkdir -p complete-app/src/main/resources

# 创建pom.xml
cat > complete-app/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example.library</groupId>
    <artifactId>complete-library-app</artifactId>
    <version>1.0.0</version>
    <name>complete-library-app</name>
    <description>Complete Library Management Application</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        
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

# 创建主应用类
cat > complete-app/src/main/java/com/example/library/LibraryApplication.java << 'EOF'
package com.example.library;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories
public class LibraryApplication {
    public static void main(String[] args) {
        SpringApplication.run(LibraryApplication.class, args);
    }
}
EOF

# 创建Book实体类
cat > complete-app/src/main/java/com/example/library/model/Book.java << 'EOF'
package com.example.library.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "books")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "ISBN不能为空")
    @Size(max = 20, message = "ISBN长度不能超过20个字符")
    @Column(unique = true, nullable = false)
    private String isbn;
    
    @NotBlank(message = "书名不能为空")
    @Size(max = 200, message = "书名长度不能超过200个字符")
    @Column(nullable = false)
    private String title;
    
    @NotBlank(message = "作者不能为空")
    @Size(max = 100, message = "作者长度不能超过100个字符")
    @Column(nullable = false)
    private String author;
    
    @Size(max = 100, message = "出版社长度不能超过100个字符")
    private String publisher;
    
    private Integer publishYear;
    
    private Double price;
    
    @Column(nullable = false)
    private Integer stockQuantity = 0;
    
    @Size(max = 1000, message = "描述长度不能超过1000个字符")
    private String description;
    
    // 构造函数
    public Book() {}
    
    public Book(String isbn, String title, String author, String publisher, 
               Integer publishYear, Double price, Integer stockQuantity, String description) {
        this.isbn = isbn;
        this.title = title;
        this.author = author;
        this.publisher = publisher;
        this.publishYear = publishYear;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.description = description;
    }
    
    // Getter和Setter方法
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getIsbn() {
        return isbn;
    }
    
    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getAuthor() {
        return author;
    }
    
    public void setAuthor(String author) {
        this.author = author;
    }
    
    public String getPublisher() {
        return publisher;
    }
    
    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }
    
    public Integer getPublishYear() {
        return publishYear;
    }
    
    public void setPublishYear(Integer publishYear) {
        this.publishYear = publishYear;
    }
    
    public Double getPrice() {
        return price;
    }
    
    public void setPrice(Double price) {
        this.price = price;
    }
    
    public Integer getStockQuantity() {
        return stockQuantity;
    }
    
    public void setStockQuantity(Integer stockQuantity) {
        this.stockQuantity = stockQuantity;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
}
EOF

# 创建BookRepository
cat > complete-app/src/main/java/com/example/library/repository/BookRepository.java << 'EOF'
package com.example.library.repository;

import com.example.library.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BookRepository extends JpaRepository<Book, Long> {
    
    Book findByIsbn(String isbn);
    
    List<Book> findByTitleContainingIgnoreCase(String title);
    
    List<Book> findByAuthorContainingIgnoreCase(String author);
    
    @Query("SELECT b FROM Book b WHERE b.title LIKE %:keyword% OR b.author LIKE %:keyword% OR b.publisher LIKE %:keyword%")
    List<Book> searchByKeyword(@Param("keyword") String keyword);
}
EOF

# 创建BookService
cat > complete-app/src/main/java/com/example/library/service/BookService.java << 'EOF'
package com.example.library.service;

import com.example.library.model.Book;
import com.example.library.repository.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BookService {
    
    @Autowired
    private BookRepository bookRepository;
    
    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }
    
    public Optional<Book> getBookById(Long id) {
        return bookRepository.findById(id);
    }
    
    public Book getBookByIsbn(String isbn) {
        return bookRepository.findByIsbn(isbn);
    }
    
    public Book saveBook(Book book) {
        return bookRepository.save(book);
    }
    
    public Book updateBook(Long id, Book bookDetails) {
        return bookRepository.findById(id)
            .map(book -> {
                book.setIsbn(bookDetails.getIsbn());
                book.setTitle(bookDetails.getTitle());
                book.setAuthor(bookDetails.getAuthor());
                book.setPublisher(bookDetails.getPublisher());
                book.setPublishYear(bookDetails.getPublishYear());
                book.setPrice(bookDetails.getPrice());
                book.setStockQuantity(bookDetails.getStockQuantity());
                book.setDescription(bookDetails.getDescription());
                return bookRepository.save(book);
            })
            .orElse(null);
    }
    
    public boolean deleteBook(Long id) {
        return bookRepository.findById(id)
            .map(book -> {
                bookRepository.delete(book);
                return true;
            })
            .orElse(false);
    }
    
    public List<Book> searchBooks(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllBooks();
        }
        return bookRepository.searchByKeyword(keyword.trim());
    }
    
    public List<Book> searchBooksByTitle(String title) {
        if (title == null || title.trim().isEmpty()) {
            return getAllBooks();
        }
        return bookRepository.findByTitleContainingIgnoreCase(title.trim());
    }
    
    public List<Book> searchBooksByAuthor(String author) {
        if (author == null || author.trim().isEmpty()) {
            return getAllBooks();
        }
        return bookRepository.findByAuthorContainingIgnoreCase(author.trim());
    }
}
EOF

# 创建BookController
cat > complete-app/src/main/java/com/example/library/controller/BookController.java << 'EOF'
package com.example.library.controller;

import com.example.library.model.Book;
import com.example.library.service.BookService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookController {
    
    @Autowired
    private BookService bookService;
    
    @GetMapping
    public ResponseEntity<List<Book>> getAllBooks() {
        List<Book> books = bookService.getAllBooks();
        return ResponseEntity.ok(books);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Book> getBookById(@PathVariable Long id) {
        Optional<Book> book = bookService.getBookById(id);
        return book.map(ResponseEntity::ok)
                  .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/isbn/{isbn}")
    public ResponseEntity<Book> getBookByIsbn(@PathVariable String isbn) {
        Book book = bookService.getBookByIsbn(isbn);
        if (book != null) {
            return ResponseEntity.ok(book);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Book>> searchBooks(@RequestParam(required = false) String keyword,
                                                @RequestParam(required = false) String title,
                                                @RequestParam(required = false) String author) {
        List<Book> books;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            books = bookService.searchBooks(keyword);
        } else if (title != null && !title.trim().isEmpty()) {
            books = bookService.searchBooksByTitle(title);
        } else if (author != null && !author.trim().isEmpty()) {
            books = bookService.searchBooksByAuthor(author);
        } else {
            books = bookService.getAllBooks();
        }
        
        return ResponseEntity.ok(books);
    }
    
    @PostMapping
    public ResponseEntity<Book> createBook(@Valid @RequestBody Book book) {
        Book savedBook = bookService.saveBook(book);
        return new ResponseEntity<>(savedBook, HttpStatus.CREATED);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Book> updateBook(@PathVariable Long id, @Valid @RequestBody Book book) {
        Book updatedBook = bookService.updateBook(id, book);
        if (updatedBook != null) {
            return ResponseEntity.ok(updatedBook);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Boolean>> deleteBook(@PathVariable Long id) {
        boolean deleted = bookService.deleteBook(id);
        Map<String, Boolean> response = new HashMap<>();
        response.put("deleted", deleted);
        
        if (deleted) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getBookStats() {
        List<Book> allBooks = bookService.getAllBooks();
        
        int totalBooks = allBooks.size();
        int totalInStock = allBooks.stream()
                               .mapToInt(Book::getStockQuantity)
                               .sum();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalBooks", totalBooks);
        stats.put("totalInStock", totalInStock);
        
        return ResponseEntity.ok(stats);
    }
}
EOF

# 创建应用配置
cat > complete-app/src/main/resources/application.properties << 'EOF'
server.port=8080
server.address=0.0.0.0

# 数据库配置
spring.datasource.url=jdbc:postgresql://postgres:5432/library
spring.datasource.username=library
spring.datasource.password=library123
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA配置
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect

# 日志级别
logging.level.org.springframework=INFO
logging.level.com.example.library=DEBUG
EOF

# 创建数据初始化
cat > complete-app/src/main/resources/data.sql << 'EOF'
-- 插入示例图书数据
INSERT INTO books (isbn, title, author, publisher, publish_year, price, stock_quantity, description) VALUES 
('978-7-111-42995-4', 'Spring实战', 'Craig Walls', '机械工业出版社', 2016, 89.00, 10, 'Spring框架的权威指南'),
('978-7-121-26382-3', 'Java核心技术卷I', 'Cay S. Horstmann', '电子工业出版社', 2018, 119.00, 5, 'Java语言的经典教程'),
('978-7-115-42031-4', '算法导论', 'Thomas H. Cormen', '人民邮电出版社', 2013, 128.00, 3, '计算机算法领域的经典教材'),
('978-7-115-47416-9', '深入理解计算机系统', 'Randal E. Bryant', '人民邮电出版社', 2016, 139.00, 7, '计算机系统的全景视角'),
('978-7-121-36931-2', 'Effective Java中文版', 'Joshua Bloch', '电子工业出版社', 2018, 89.00, 12, 'Java编程的最佳实践'),
('978-7-121-32016-8', '设计模式', 'Erich Gamma等', '机械工业出版社', 2007, 35.00, 8, '面向对象软件设计的经典');
EOF

# 4. 构建应用
echo ""
echo "3. 构建完整应用..."
cd complete-app

# 设置Maven内存限制
export MAVEN_OPTS="-Xmx1024m"

# 构建项目
mvn clean package -DskipTests

# 检查构建结果
if [ -f "target/complete-library-app-1.0.0.jar" ]; then
    echo "✅ JAR文件构建成功"
    ls -lh target/complete-library-app-1.0.0.jar
    
    # 复制到主目录
    cp target/complete-library-app-1.0.0.jar ../complete-library-management-system.jar
    echo "已复制到主目录"
else
    echo "❌ JAR文件构建失败"
    exit 1
fi

cd ..

# 5. 创建完整的前端页面
echo ""
echo "4. 创建完整的前端页面..."
mkdir -p frontend-vue/dist
cat > frontend-vue/dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
        }
        .navbar {
            background-color: #4a6bdf;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 1rem;
        }
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }
        .card-header {
            background-color: #4a6bdf;
            color: white;
            font-weight: bold;
            border-radius: 10px 10px 0 0 !important;
        }
        .btn-primary {
            background-color: #4a6bdf;
            border-color: #4a6bdf;
        }
        .btn-primary:hover {
            background-color: #3a5bcf;
            border-color: #3a5bcf;
        }
        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
        }
        .book-card {
            height: 100%;
            transition: transform 0.3s ease;
        }
        .book-card:hover {
            transform: translateY(-5px);
        }
        .stats-card {
            text-align: center;
            padding: 1.5rem;
        }
        .stats-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #4a6bdf;
        }
        .search-box {
            background: white;
            border-radius: 50px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 0.75rem 1.5rem;
            margin-bottom: 2rem;
        }
        .search-box input {
            border: none;
            outline: none;
            width: 100%;
            font-size: 1rem;
        }
        .loading {
            text-align: center;
            padding: 2rem;
            color: #6c757d;
        }
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #6c757d;
        }
        .table-responsive {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 1rem;
            margin-bottom: 2rem;
        }
        .view-toggle button {
            margin-right: 0.5rem;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="#">
                <i class="bi bi-book"></i> 图书管理系统
            </a>
            <div class="navbar-nav ms-auto">
                <a class="nav-link active" href="#" id="home-link">
                    <i class="bi bi-house-door"></i> 首页
                </a>
                <a class="nav-link" href="#" id="books-link">
                    <i class="bi bi-journal-text"></i> 图书管理
                </a>
            </div>
        </div>
    </nav>

    <div class="container">
        <div id="home-view">
            <!-- 统计信息 -->
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card stats-card">
                        <div class="stats-number" id="total-books">0</div>
                        <div>图书总数</div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card stats-card">
                        <div class="stats-number" id="total-stock">0</div>
                        <div>库存总量</div>
                    </div>
                </div>
            </div>

            <!-- 搜索框 -->
            <div class="search-box">
                <div class="input-group">
                    <input type="text" id="search-input" class="form-control" placeholder="搜索图书...">
                    <button class="btn btn-primary" id="search-btn">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </div>

            <!-- 图书列表 -->
            <div class="book-grid" id="book-grid">
                <div class="loading">
                    <div class="spinner-border" role="status">
                        <span class="visually-hidden">加载中...</span>
                    </div>
                    <p>正在加载图书信息...</p>
                </div>
            </div>
        </div>

        <div id="books-view" style="display:none;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2>图书管理</h2>
                <div class="view-toggle">
                    <button class="btn btn-outline-primary" id="grid-view-btn">
                        <i class="bi bi-grid-3x3-gap"></i> 网格视图
                    </button>
                    <button class="btn btn-outline-primary" id="table-view-btn">
                        <i class="bi bi-table"></i> 表格视图
                    </button>
                </div>
            </div>

            <!-- 搜索框 -->
            <div class="search-box">
                <div class="input-group">
                    <input type="text" id="search-input-table" class="form-control" placeholder="搜索图书...">
                    <button class="btn btn-primary" id="search-btn-table">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </div>

            <!-- 图书表格视图 -->
            <div class="table-responsive" id="table-view">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>ISBN</th>
                            <th>书名</th>
                            <th>作者</th>
                            <th>出版社</th>
                            <th>出版年份</th>
                            <th>价格</th>
                            <th>库存</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody id="book-table-body">
                        <tr>
                            <td colspan="8" class="text-center">
                                <div class="spinner-border" role="status">
                                    <span class="visually-hidden">加载中...</span>
                                </div>
                                <p>正在加载图书信息...</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- 图书网格视图 -->
            <div class="book-grid" id="grid-view-books">
                <div class="loading">
                    <div class="spinner-border" role="status">
                        <span class="visually-hidden">加载中...</span>
                    </div>
                    <p>正在加载图书信息...</p>
                </div>
            </div>
        </div>
    </div>

    <!-- 添加/编辑图书模态框 -->
    <div class="modal fade" id="bookModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="bookModalTitle">添加图书</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="bookForm">
                        <input type="hidden" id="bookId">
                        <div class="mb-3">
                            <label for="bookIsbn" class="form-label">ISBN</label>
                            <input type="text" class="form-control" id="bookIsbn" required>
                        </div>
                        <div class="mb-3">
                            <label for="bookTitle" class="form-label">书名</label>
                            <input type="text" class="form-control" id="bookTitle" required>
                        </div>
                        <div class="mb-3">
                            <label for="bookAuthor" class="form-label">作者</label>
                            <input type="text" class="form-control" id="bookAuthor" required>
                        </div>
                        <div class="mb-3">
                            <label for="bookPublisher" class="form-label">出版社</label>
                            <input type="text" class="form-control" id="bookPublisher">
                        </div>
                        <div class="mb-3">
                            <label for="bookPublishYear" class="form-label">出版年份</label>
                            <input type="number" class="form-control" id="bookPublishYear">
                        </div>
                        <div class="mb-3">
                            <label for="bookPrice" class="form-label">价格</label>
                            <input type="number" step="0.01" class="form-control" id="bookPrice">
                        </div>
                        <div class="mb-3">
                            <label for="bookStock" class="form-label">库存数量</label>
                            <input type="number" class="form-control" id="bookStock" required>
                        </div>
                        <div class="mb-3">
                            <label for="bookDescription" class="form-label">描述</label>
                            <textarea class="form-control" id="bookDescription" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="button" class="btn btn-primary" id="saveBookBtn">保存</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 全局变量
        let books = [];
        let currentView = 'home';
        let booksViewMode = 'grid';

        // API地址
        const API_URL = 'http://150.158.125.55:8080/api/books';

        // 页面加载时获取数据
        document.addEventListener('DOMContentLoaded', function() {
            loadBooks();
            loadStats();
            
            // 导航链接事件
            document.getElementById('home-link').addEventListener('click', function(e) {
                e.preventDefault();
                showHomeView();
            });
            
            document.getElementById('books-link').addEventListener('click', function(e) {
                e.preventDefault();
                showBooksView();
            });
            
            // 搜索按钮事件
            document.getElementById('search-btn').addEventListener('click', searchBooks);
            document.getElementById('search-input').addEventListener('keyup', function(e) {
                if (e.key === 'Enter') {
                    searchBooks();
                }
            });
            
            document.getElementById('search-btn-table').addEventListener('click', searchBooks);
            document.getElementById('search-input-table').addEventListener('keyup', function(e) {
                if (e.key === 'Enter') {
                    searchBooks();
                }
            });
            
            // 视图切换按钮
            document.getElementById('grid-view-btn').addEventListener('click', function() {
                showBooksGrid();
            });
            
            document.getElementById('table-view-btn').addEventListener('click', function() {
                showBooksTable();
            });
            
            // 保存图书按钮
            document.getElementById('saveBookBtn').addEventListener('click', saveBook);
        });

        // 显示首页视图
        function showHomeView() {
            document.getElementById('home-view').style.display = 'block';
            document.getElementById('books-view').style.display = 'none';
            
            // 更新导航状态
            document.getElementById('home-link').classList.add('active');
            document.getElementById('books-link').classList.remove('active');
            
            currentView = 'home';
        }

        // 显示图书管理视图
        function showBooksView() {
            document.getElementById('home-view').style.display = 'none';
            document.getElementById('books-view').style.display = 'block';
            
            // 更新导航状态
            document.getElementById('home-link').classList.remove('active');
            document.getElementById('books-link').classList.add('active');
            
            currentView = 'books';
            
            // 根据当前模式显示视图
            if (booksViewMode === 'grid') {
                showBooksGrid();
            } else {
                showBooksTable();
            }
        }

        // 显示图书网格视图
        function showBooksGrid() {
            document.getElementById('grid-view-books').style.display = 'block';
            document.getElementById('table-view').style.display = 'none';
            document.getElementById('grid-view-btn').classList.remove('btn-outline-primary');
            document.getElementById('grid-view-btn').classList.add('btn-primary');
            document.getElementById('table-view-btn').classList.remove('btn-primary');
            document.getElementById('table-view-btn').classList.add('btn-outline-primary');
            
            booksViewMode = 'grid';
            renderBooksGrid(books);
        }

        // 显示图书表格视图
        function showBooksTable() {
            document.getElementById('grid-view-books').style.display = 'none';
            document.getElementById('table-view').style.display = 'block';
            document.getElementById('table-view-btn').classList.remove('btn-outline-primary');
            document.getElementById('table-view-btn').classList.add('btn-primary');
            document.getElementById('grid-view-btn').classList.remove('btn-primary');
            document.getElementById('grid-view-btn').classList.add('btn-outline-primary');
            
            booksViewMode = 'table';
            renderBooksTable(books);
        }

        // 加载图书数据
        function loadBooks() {
            fetch(API_URL)
                .then(response => response.json())
                .then(data => {
                    books = data;
                    renderBooksGrid(books);
                })
                .catch(error => {
                    console.error('加载图书数据失败:', error);
                    document.getElementById('book-grid').innerHTML = `
                        <div class="empty-state">
                            <i class="bi bi-exclamation-triangle" style="font-size: 3rem;"></i>
                            <h5>加载失败</h5>
                            <p>无法加载图书数据，请检查网络连接</p>
                            <button class="btn btn-primary" onclick="loadBooks()">重试</button>
                        </div>
                    `;
                });
        }

        // 加载统计数据
        function loadStats() {
            fetch(API_URL + '/stats')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('total-books').textContent = data.totalBooks;
                    document.getElementById('total-stock').textContent = data.totalInStock;
                })
                .catch(error => {
                    console.error('加载统计数据失败:', error);
                });
        }

        // 搜索图书
        function searchBooks() {
            const keyword = currentView === 'home' 
                ? document.getElementById('search-input').value 
                : document.getElementById('search-input-table').value;
            
            fetch(API_URL + '/search?keyword=' + encodeURIComponent(keyword))
                .then(response => response.json())
                .then(data => {
                    books = data;
                    if (booksViewMode === 'grid' || currentView === 'home') {
                        renderBooksGrid(books);
                    } else {
                        renderBooksTable(books);
                    }
                })
                .catch(error => {
                    console.error('搜索失败:', error);
                });
        }

        // 渲染图书网格
        function renderBooksGrid(booksToRender) {
            const grid = currentView === 'home' 
                ? document.getElementById('book-grid') 
                : document.getElementById('grid-view-books');
                
            if (booksToRender.length === 0) {
                grid.innerHTML = `
                    <div class="empty-state">
                        <i class="bi bi-search" style="font-size: 3rem;"></i>
                        <h5>没有找到图书</h5>
                        <p>尝试其他搜索条件</p>
                    </div>
                `;
                return;
            }

            grid.innerHTML = booksToRender.map(book => `
                <div class="card book-card">
                    <div class="card-body">
                        <h5 class="card-title">${book.title}</h5>
                        <p class="card-text">
                            <strong>作者:</strong> ${book.author}<br>
                            <strong>ISBN:</strong> ${book.isbn}<br>
                            ${book.publisher ? `<strong>出版社:</strong> ${book.publisher}<br>` : ''}
                            ${book.publishYear ? `<strong>出版年份:</strong> ${book.publishYear}<br>` : ''}
                            ${book.price ? `<strong>价格:</strong> ¥${book.price}<br>` : ''}
                            <strong>库存:</strong> ${book.stockQuantity}
                        </p>
                        ${book.description ? `<p class="card-text">${book.description.substring(0, 100)}${book.description.length > 100 ? '...' : ''}</p>` : ''}
                    </div>
                </div>
            `).join('');
        }

        // 渲染图书表格
        function renderBooksTable(booksToRender) {
            const tbody = document.getElementById('book-table-body');
            
            if (booksToRender.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="8" class="text-center">
                            <div class="empty-state">
                                <i class="bi bi-search" style="font-size: 2rem;"></i>
                                <h5>没有找到图书</h5>
                                <p>尝试其他搜索条件</p>
                            </div>
                        </td>
                    </tr>
                `;
                return;
            }

            tbody.innerHTML = booksToRender.map(book => `
                <tr>
                    <td>${book.isbn}</td>
                    <td>${book.title}</td>
                    <td>${book.author}</td>
                    <td>${book.publisher || ''}</td>
                    <td>${book.publishYear || ''}</td>
                    <td>${book.price ? '¥' + book.price : ''}</td>
                    <td>${book.stockQuantity}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary" onclick="editBook(${book.id})">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="deleteBook(${book.id})">
                            <i class="bi bi-trash"></i>
                        </button>
                    </td>
                </tr>
            `).join('');
        }

        // 编辑图书
        function editBook(id) {
            const book = books.find(b => b.id === id);
            if (book) {
                document.getElementById('bookId').value = book.id;
                document.getElementById('bookIsbn').value = book.isbn;
                document.getElementById('bookTitle').value = book.title;
                document.getElementById('bookAuthor').value = book.author;
                document.getElementById('bookPublisher').value = book.publisher || '';
                document.getElementById('bookPublishYear').value = book.publishYear || '';
                document.getElementById('bookPrice').value = book.price || '';
                document.getElementById('bookStock').value = book.stockQuantity;
                document.getElementById('bookDescription').value = book.description || '';
                
                document.getElementById('bookModalTitle').textContent = '编辑图书';
                
                const modal = new bootstrap.Modal(document.getElementById('bookModal'));
                modal.show();
            }
        }

        // 删除图书
        function deleteBook(id) {
            if (confirm('确定要删除这本图书吗？')) {
                fetch(API_URL + '/' + id, {
                    method: 'DELETE'
                })
                .then(response => {
                    if (response.ok) {
                        loadBooks();
                        loadStats();
                        alert('图书已删除');
                    } else {
                        alert('删除失败');
                    }
                })
                .catch(error => {
                    console.error('删除失败:', error);
                    alert('删除失败');
                });
            }
        }

        // 保存图书
        function saveBook() {
            const id = document.getElementById('bookId').value;
            const bookData = {
                isbn: document.getElementById('bookIsbn').value,
                title: document.getElementById('bookTitle').value,
                author: document.getElementById('bookAuthor').value,
                publisher: document.getElementById('bookPublisher').value,
                publishYear: document.getElementById('bookPublishYear').value ? 
                            parseInt(document.getElementById('bookPublishYear').value) : null,
                price: document.getElementById('bookPrice').value ? 
                       parseFloat(document.getElementById('bookPrice').value) : null,
                stockQuantity: parseInt(document.getElementById('bookStock').value),
                description: document.getElementById('bookDescription').value
            };
            
            const url = id ? API_URL + '/' + id : API_URL;
            const method = id ? 'PUT' : 'POST';
            
            fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(bookData)
            })
            .then(response => {
                if (response.ok) {
                    const modal = bootstrap.Modal.getInstance(document.getElementById('bookModal'));
                    modal.hide();
                    
                    loadBooks();
                    loadStats();
                    alert(id ? '图书已更新' : '图书已添加');
                } else {
                    alert('保存失败');
                }
            })
            .catch(error => {
                console.error('保存失败:', error);
                alert('保存失败');
            });
        }
    </script>
</body>
</html>
EOF

# 6. 启动后端服务
echo ""
echo "5. 启动后端服务..."
docker run -d --name library-backend \
  --network library-network \
  -p 8080:8080 \
  -v $(pwd)/complete-library-management-system.jar:/app.jar \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 7. 启动前端服务
echo ""
echo "6. 启动前端服务..."
docker run -d --name library-frontend \
  --network library-network \
  -p 3000:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 8. 等待服务启动
echo ""
echo "7. 等待服务启动..."
sleep 60

# 9. 测试服务
echo ""
echo "8. 测试服务..."
echo "测试前端服务..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
echo "状态码: $FRONTEND_STATUS"

echo ""
echo "测试后端服务..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
echo "状态码: $BACKEND_STATUS"

echo ""
echo "测试API健康检查..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/books 2>/dev/null || echo "000")
echo "状态码: $HEALTH_STATUS"

# 10. 显示访问地址
echo ""
echo "=== 完整系统部署完成 ==="
echo ""
echo "🎉 图书管理系统已成功部署！"
echo ""
echo "访问地址："
echo "前端应用: http://$EXTERNAL_IP:3000"
echo "后端API: http://$EXTERNAL_IP:8080"
echo ""
echo "API端点："
echo "图书列表: http://$EXTERNAL_IP:8080/api/books"
echo "图书搜索: http://$EXTERNAL_IP:8080/api/books/search?keyword=Spring"
echo "图书统计: http://$EXTERNAL_IP:8080/api/books/stats"
echo ""
echo "容器状态："
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"