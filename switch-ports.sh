#!/bin/bash

# 图书管理系统 - 交换前后端端口

set -e

echo "=== 交换前后端端口 ==="
echo ""

# 1. 获取服务器IP
EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "150.158.125.55")
echo "服务器IP: $EXTERNAL_IP"

# 2. 停止当前容器
echo ""
echo "1. 停止当前容器..."
docker stop library-backend library-frontend 2>/dev/null || true
docker rm library-backend library-frontend 2>/dev/null || true

# 3. 修改前端页面中的API地址
echo ""
echo "2. 修改前端页面中的API地址..."
mkdir -p frontend-vue/dist

# 创建新的前端页面，使用端口8080，API地址改为3000
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
            transition: transform 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
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
        .login-container {
            max-width: 400px;
            margin: 5rem auto;
        }
        .login-card {
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .login-header {
            background: linear-gradient(135deg, #4a6bdf, #6b8aef);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        .login-body {
            padding: 2rem;
        }
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 5px;
            color: white;
            z-index: 1000;
            display: none;
        }
        .notification.success {
            background-color: #28a745;
        }
        .notification.error {
            background-color: #dc3545;
        }
        .port-info {
            background-color: #e7f3ff;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div id="notification" class="notification"></div>

    <!-- 登录视图 -->
    <div id="login-view">
        <div class="container">
            <div class="login-container">
                <div class="login-card">
                    <div class="login-header">
                        <h2>图书管理系统</h2>
                        <p>请登录以访问系统</p>
                    </div>
                    <div class="login-body">
                        <div class="port-info">
                            <strong>端口已更改：</strong><br>
                            前端: 8080 | 后端API: 3000
                        </div>
                        <form id="login-form">
                            <div class="mb-3">
                                <label for="username" class="form-label">用户名</label>
                                <input type="text" class="form-control" id="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">密码</label>
                                <input type="password" class="form-control" id="password" required>
                            </div>
                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="remember-me">
                                <label class="form-check-label" for="remember-me">记住我</label>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">登录</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 主应用视图 -->
    <div id="app-view" style="display: none;">
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
                    <a class="nav-link" href="#" id="logout-link">
                        <i class="bi bi-box-arrow-right"></i> 退出
                    </a>
                </div>
            </div>
        </nav>

        <div class="container">
            <div id="home-view">
                <div class="port-info">
                    <strong>端口已更改：</strong><br>
                    前端: 8080 | 后端API: 3000
                </div>
                
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
                    <div>
                        <button class="btn btn-primary" id="add-book-btn">
                            <i class="bi bi-plus-circle"></i> 添加图书
                        </button>
                        <div class="view-toggle d-inline-block ms-2">
                            <button class="btn btn-outline-primary" id="grid-view-btn">
                                <i class="bi bi-grid-3x3-gap"></i> 网格视图
                            </button>
                            <button class="btn btn-outline-primary" id="table-view-btn">
                                <i class="bi bi-table"></i> 表格视图
                            </button>
                        </div>
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
        let isLoggedIn = false;

        // API地址 - 修改为端口3000
        const API_URL = 'http://150.158.125.55:3000/api/books';

        // 页面加载时检查登录状态
        document.addEventListener('DOMContentLoaded', function() {
            checkLoginStatus();
        });

        // 检查登录状态
        function checkLoginStatus() {
            const token = localStorage.getItem('library_token');
            if (token) {
                isLoggedIn = true;
                showAppView();
            } else {
                showLoginView();
            }
        }

        // 显示登录视图
        function showLoginView() {
            document.getElementById('login-view').style.display = 'block';
            document.getElementById('app-view').style.display = 'none';
        }

        // 显示应用视图
        function showAppView() {
            document.getElementById('login-view').style.display = 'none';
            document.getElementById('app-view').style.display = 'block';
            
            // 初始化应用
            initApp();
        }

        // 初始化应用
        function initApp() {
            loadBooks();
            loadStats();
            
            // 登录表单事件
            document.getElementById('login-form').addEventListener('submit', function(e) {
                e.preventDefault();
                handleLogin();
            });
            
            // 导航链接事件
            document.getElementById('home-link').addEventListener('click', function(e) {
                e.preventDefault();
                showHomeView();
            });
            
            document.getElementById('books-link').addEventListener('click', function(e) {
                e.preventDefault();
                showBooksView();
            });
            
            document.getElementById('logout-link').addEventListener('click', function(e) {
                e.preventDefault();
                handleLogout();
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
            
            // 添加图书按钮
            document.getElementById('add-book-btn').addEventListener('click', function() {
                openBookModal();
            });
            
            // 保存图书按钮
            document.getElementById('saveBookBtn').addEventListener('click', saveBook);
        }

        // 处理登录
        function handleLogin() {
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            
            // 模拟登录验证（实际应用中应该调用后端API）
            if ((username === 'admin' && password === 'admin123') || 
                (username === 'reader' && password === 'reader123')) {
                
                // 保存登录状态
                localStorage.setItem('library_token', 'fake-jwt-token');
                localStorage.setItem('library_user', username);
                
                // 显示通知
                showNotification('登录成功！', 'success');
                
                // 显示应用视图
                setTimeout(() => {
                    isLoggedIn = true;
                    showAppView();
                }, 1000);
            } else {
                showNotification('用户名或密码错误！', 'error');
            }
        }

        // 处理退出
        function handleLogout() {
            // 清除登录状态
            localStorage.removeItem('library_token');
            localStorage.removeItem('library_user');
            
            // 显示通知
            showNotification('已成功退出！', 'success');
            
            // 显示登录视图
            setTimeout(() => {
                isLoggedIn = false;
                showLoginView();
            }, 1000);
        }

        // 显示通知
        function showNotification(message, type) {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification ' + type;
            notification.style.display = 'block';
            
            setTimeout(() => {
                notification.style.display = 'none';
            }, 3000);
        }

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
            // 显示加载状态
            const gridElement = document.getElementById('book-grid');
            const gridBooksElement = document.getElementById('grid-view-books');
            
            if (gridElement) {
                gridElement.innerHTML = `
                    <div class="loading">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">加载中...</span>
                        </div>
                        <p>正在加载图书信息...</p>
                    </div>
                `;
            }
            
            if (gridBooksElement) {
                gridBooksElement.innerHTML = `
                    <div class="loading">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">加载中...</span>
                        </div>
                        <p>正在加载图书信息...</p>
                    </div>
                `;
            }
            
            // 尝试使用fetch API
            fetch(API_URL, {
                method: 'GET',
                mode: 'cors',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('网络响应异常: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                books = data;
                renderBooksGrid(books);
                
                // 更新表格视图（如果当前是表格视图）
                if (booksViewMode === 'table') {
                    renderBooksTable(books);
                }
            })
            .catch(error => {
                console.error('加载图书数据失败:', error);
                
                // 如果fetch失败，使用示例数据
                books = getSampleBooks();
                renderBooksGrid(books);
                
                // 更新表格视图（如果当前是表格视图）
                if (booksViewMode === 'table') {
                    renderBooksTable(books);
                }
                
                showNotification('无法连接到服务器，显示示例数据', 'error');
            });
        }

        // 获取示例数据
        function getSampleBooks() {
            return [
                {
                    id: 1,
                    isbn: "978-7-111-42995-4",
                    title: "Spring实战",
                    author: "Craig Walls",
                    publisher: "机械工业出版社",
                    publishYear: 2016,
                    price: 89.00,
                    stockQuantity: 10,
                    description: "Spring框架的权威指南"
                },
                {
                    id: 2,
                    isbn: "978-7-121-26382-3",
                    title: "Java核心技术卷I",
                    author: "Cay S. Horstmann",
                    publisher: "电子工业出版社",
                    publishYear: 2018,
                    price: 119.00,
                    stockQuantity: 5,
                    description: "Java语言的经典教程"
                },
                {
                    id: 3,
                    isbn: "978-7-115-42031-4",
                    title: "算法导论",
                    author: "Thomas H. Cormen",
                    publisher: "人民邮电出版社",
                    publishYear: 2013,
                    price: 128.00,
                    stockQuantity: 3,
                    description: "计算机算法领域的经典教材"
                }
            ];
        }

        // 加载统计数据
        function loadStats() {
            // 计算统计信息
            if (books.length > 0) {
                const totalBooks = books.length;
                const totalInStock = books.reduce((sum, book) => sum + book.stockQuantity, 0);
                
                document.getElementById('total-books').textContent = totalBooks;
                document.getElementById('total-stock').textContent = totalInStock;
            } else {
                // 显示默认值
                document.getElementById('total-books').textContent = '0';
                document.getElementById('total-stock').textContent = '0';
            }
        }

        // 搜索图书
        function searchBooks() {
            const keyword = currentView === 'home' 
                ? document.getElementById('search-input').value 
                : document.getElementById('search-input-table').value;
            
            if (!keyword.trim()) {
                renderBooksGrid(books);
                if (booksViewMode === 'table') {
                    renderBooksTable(books);
                }
                return;
            }
            
            // 本地搜索
            const filteredBooks = books.filter(book => 
                book.title.toLowerCase().includes(keyword.toLowerCase()) ||
                book.author.toLowerCase().includes(keyword.toLowerCase()) ||
                book.publisher.toLowerCase().includes(keyword.toLowerCase()) ||
                book.isbn.includes(keyword)
            );
            
            renderBooksGrid(filteredBooks);
            if (booksViewMode === 'table') {
                renderBooksTable(filteredBooks);
            }
        }

        // 渲染图书网格
        function renderBooksGrid(booksToRender) {
            const grid = currentView === 'home' 
                ? document.getElementById('book-grid') 
                : document.getElementById('grid-view-books');
                
            if (!grid) return;
                
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
            if (!tbody) return;
            
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

        // 打开图书模态框
        function openBookModal(bookId) {
            const book = bookId ? books.find(b => b.id === bookId) : null;
            
            // 重置表单
            document.getElementById('bookForm').reset();
            
            if (book) {
                // 编辑模式
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
            } else {
                // 添加模式
                document.getElementById('bookId').value = '';
                document.getElementById('bookModalTitle').textContent = '添加图书';
            }
            
            const modal = new bootstrap.Modal(document.getElementById('bookModal'));
            modal.show();
        }

        // 编辑图书
        function editBook(id) {
            openBookModal(id);
        }

        // 删除图书
        function deleteBook(id) {
            if (confirm('确定要删除这本图书吗？')) {
                // 本地删除（实际应用中应该调用API）
                books = books.filter(book => book.id !== id);
                
                // 刷新视图
                renderBooksGrid(books);
                if (booksViewMode === 'table') {
                    renderBooksTable(books);
                }
                
                // 更新统计
                loadStats();
                
                showNotification('图书已删除', 'success');
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
            
            // 本地保存（实际应用中应该调用API）
            if (id) {
                // 编辑模式
                const index = books.findIndex(book => book.id == id);
                if (index !== -1) {
                    books[index] = { ...books[index], ...bookData };
                    showNotification('图书已更新', 'success');
                }
            } else {
                // 添加模式
                const newId = books.length > 0 ? Math.max(...books.map(b => b.id)) + 1 : 1;
                books.push({ id: newId, ...bookData });
                showNotification('图书已添加', 'success');
            }
            
            // 关闭模态框
            const modal = bootstrap.Modal.getInstance(document.getElementById('bookModal'));
            modal.hide();
            
            // 刷新视图
            renderBooksGrid(books);
            if (booksViewMode === 'table') {
                renderBooksTable(books);
            }
            
            // 更新统计
            loadStats();
        }
    </script>
</body>
</html>
EOF

# 4. 修改后端配置（如果需要）
if [ -f "complete-app/src/main/resources/application.properties" ]; then
    echo ""
    echo "3. 修改后端配置文件..."
    # 备份原始文件
    cp complete-app/src/main/resources/application.properties complete-app/src/main/resources/application.properties.backup
    
    # 修改端口配置
    sed -i 's/server.port=8080/server.port=3000/g' complete-app/src/main/resources/application.properties
    
    echo "已修改后端端口为3000"
fi

# 5. 重新构建后端（如果配置文件有变化）
if [ -f "complete-app/src/main/resources/application.properties.backup" ]; then
    echo ""
    echo "4. 重新构建后端..."
    cd complete-app
    
    # 设置Maven内存限制
    export MAVEN_OPTS="-Xmx1024m"
    
    # 构建项目
    mvn clean package -DskipTests
    
    # 检查构建结果
    if [ -f "target/complete-library-app-1.0.0.jar" ]; then
        echo "✅ JAR文件构建成功"
        # 复制到主目录
        cp target/complete-library-app-1.0.0.jar ../complete-library-management-system.jar
        echo "已复制到主目录"
    else
        echo "❌ JAR文件构建失败"
        exit 1
    fi
    
    cd ..
fi

# 6. 启动后端服务（使用端口3000）
echo ""
echo "5. 启动后端服务（端口3000）..."
docker run -d --name library-backend \
  --network library-network \
  -p 3000:3000 \
  -v $(pwd)/complete-library-management-system.jar:/app.jar \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/library \
  -e SPRING_DATASOURCE_USERNAME=library \
  -e SPRING_DATASOURCE_PASSWORD=library123 \
  openjdk:17-jdk-slim \
  java -jar -Dserver.address=0.0.0.0 /app.jar

# 7. 启动前端服务（使用端口8080）
echo ""
echo "6. 启动前端服务（端口8080）..."
docker run -d --name library-frontend \
  --network library-network \
  -p 8080:80 \
  -v $(pwd)/frontend-vue/dist:/usr/share/nginx/html:ro \
  nginx:alpine

# 8. 等待服务启动
echo ""
echo "7. 等待服务启动..."
sleep 30

# 9. 测试服务
echo ""
echo "8. 测试服务..."
echo "测试前端服务（端口8080）..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")
echo "状态码: $FRONTEND_STATUS"

echo ""
echo "测试后端服务（端口3000）..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "000")
echo "状态码: $BACKEND_STATUS"

echo ""
echo "测试API端点（端口3000）..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/books 2>/dev/null || echo "000")
echo "状态码: $API_STATUS"

# 10. 显示访问地址和登录信息
echo ""
echo "=== 端口交换完成 ==="
echo ""
echo "🎉 端口已成功交换！"
echo ""
echo "访问地址："
echo "前端应用: http://$EXTERNAL_IP:8080"
echo "后端API: http://$EXTERNAL_IP:3000"
echo ""
echo "API端点："
echo "图书列表: http://$EXTERNAL_IP:3000/api/books"
echo "图书搜索: http://$EXTERNAL_IP:3000/api/books/search?keyword=Spring"
echo "图书统计: http://$EXTERNAL_IP:3000/api/books/stats"
echo ""
echo "后端登录信息："
echo "注意：当前后端未配置安全认证，因此不需要用户名密码"
echo "如果需要添加安全认证，可以配置Spring Security"
echo ""
echo "前端登录账号："
echo "管理员: admin / admin123"
echo "读者: reader / reader123"
echo ""
echo "容器状态："
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"