// 全局变量
let currentUser = null;
let currentPage = 0;
let totalPages = 0;
let currentSearchTerm = '';

// API基础URL
const API_BASE_URL = '/api';

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 检查是否已登录
    const token = localStorage.getItem('token');
    if (token) {
        getCurrentUser();
    } else {
        showLogin();
    }

    // 绑定事件
    bindEvents();
});

// 绑定事件
function bindEvents() {
    // 登录表单提交
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        e.preventDefault();
        login();
    });

    // 退出登录
    document.getElementById('logoutBtn').addEventListener('click', function(e) {
        e.preventDefault();
        logout();
    });

    // 侧边栏导航
    document.querySelectorAll('.nav-link[data-page]').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const page = this.getAttribute('data-page');
            showPage(page + 'Page');
            
            // 更新活动状态
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            this.classList.add('active');
        });
    });

    // 添加图书表单
    document.getElementById('addBookForm').addEventListener('submit', function(e) {
        e.preventDefault();
        addBook();
    });

    // 高级搜索表单
    document.getElementById('advancedSearchForm').addEventListener('submit', function(e) {
        e.preventDefault();
        advancedSearch();
    });

    // 快速搜索输入框回车事件
    document.getElementById('quickSearchInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            quickSearch();
        }
    });
}

// 显示登录页面
function showLogin() {
    document.getElementById('loginPage').classList.remove('d-none');
    document.getElementById('mainApp').classList.add('d-none');
}

// 显示主应用
function showMainApp() {
    document.getElementById('loginPage').classList.add('d-none');
    document.getElementById('mainApp').classList.remove('d-none');
    loadBooks();
}

// 显示指定页面
function showPage(pageId) {
    document.querySelectorAll('.page-content').forEach(page => {
        page.classList.add('d-none');
    });
    document.getElementById(pageId).classList.remove('d-none');
}

// 登录
async function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password })
        });

        if (response.ok) {
            const data = await response.json();
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data));
            currentUser = data;
            showMainApp();
            updateUserInfo();
        } else {
            const error = await response.text();
            alert('登录失败: ' + error);
        }
    } catch (error) {
        alert('登录失败: ' + error.message);
    }
}

// 退出登录
function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    currentUser = null;
    showLogin();
}

// 获取当前用户信息
async function getCurrentUser() {
    const token = localStorage.getItem('token');
    if (!token) {
        showLogin();
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/auth/me`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (response.ok) {
            const data = await response.json();
            currentUser = data;
            showMainApp();
            updateUserInfo();
        } else {
            logout();
        }
    } catch (error) {
        logout();
    }
}

// 更新用户信息显示
function updateUserInfo() {
    if (currentUser) {
        document.getElementById('currentUser').textContent = currentUser.username;
        document.getElementById('userRole').textContent = currentUser.role === 'ADMIN' ? '管理员' : '读者';
        
        // 如果是管理员，显示管理菜单
        if (currentUser.role === 'ADMIN') {
            document.getElementById('adminMenu').style.display = 'block';
        }
    }
}

// 加载图书列表
async function loadBooks(page = 0, searchTerm = '') {
    const token = localStorage.getItem('token');
    let url = `${API_BASE_URL}/books?page=${page}&size=12&sortBy=title&sortDir=asc`;
    
    if (searchTerm) {
        url = `${API_BASE_URL}/books/search?title=${searchTerm}&page=${page}&size=12&sortBy=title&sortDir=asc`;
    }

    try {
        const response = await fetch(url, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (response.ok) {
            const data = await response.json();
            displayBooks(data.content);
            updatePagination(data);
            document.getElementById('totalBooks').textContent = data.totalElements;
        } else {
            alert('加载图书失败');
        }
    } catch (error) {
        alert('加载图书失败: ' + error.message);
    }
}

// 显示图书列表
function displayBooks(books) {
    const booksList = document.getElementById('booksList');
    booksList.innerHTML = '';

    if (books.length === 0) {
        booksList.innerHTML = '<div class="col-12"><div class="alert alert-info">没有找到图书</div></div>';
        return;
    }

    books.forEach(book => {
        const bookCard = createBookCard(book);
        booksList.appendChild(bookCard);
    });
}

// 创建图书卡片
function createBookCard(book) {
    const col = document.createElement('div');
    col.className = 'col-md-4 mb-3';
    
    const isAdmin = currentUser && currentUser.role === 'ADMIN';
    
    col.innerHTML = `
        <div class="card book-card h-100">
            <div class="card-body">
                <h5 class="card-title">${book.title}</h5>
                <p class="card-text">
                    <strong>作者:</strong> ${book.author}<br>
                    <strong>出版社:</strong> ${book.publisher}<br>
                    <strong>ISBN:</strong> ${book.isbn}<br>
                    <strong>出版年份:</strong> ${book.publishYear}<br>
                    <strong>价格:</strong> ¥${book.price.toFixed(2)}<br>
                    <strong>库存:</strong> ${book.stockQuantity}
                </p>
                ${book.description ? `<p class="card-text text-muted">${book.description.substring(0, 50)}...</p>` : ''}
            </div>
            ${isAdmin ? `
            <div class="card-footer">
                <button class="btn btn-sm btn-primary" onclick="editBook(${book.id})">
                    <i class="fas fa-edit"></i> 编辑
                </button>
                <button class="btn btn-sm btn-danger" onclick="deleteBook(${book.id})">
                    <i class="fas fa-trash"></i> 删除
                </button>
            </div>
            ` : ''}
        </div>
    `;
    
    return col;
}

// 更新分页
function updatePagination(data) {
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = '';

    if (data.totalPages <= 1) return;

    // 上一页
    const prevLi = document.createElement('li');
    prevLi.className = `page-item ${data.first ? 'disabled' : ''}`;
    prevLi.innerHTML = `<a class="page-link" href="#" onclick="loadBooks(${data.number - 1}, '${currentSearchTerm}')">上一页</a>`;
    pagination.appendChild(prevLi);

    // 页码
    for (let i = Math.max(0, data.number - 2); i <= Math.min(data.totalPages - 1, data.number + 2); i++) {
        const li = document.createElement('li');
        li.className = `page-item ${i === data.number ? 'active' : ''}`;
        li.innerHTML = `<a class="page-link" href="#" onclick="loadBooks(${i}, '${currentSearchTerm}')">${i + 1}</a>`;
        pagination.appendChild(li);
    }

    // 下一页
    const nextLi = document.createElement('li');
    nextLi.className = `page-item ${data.last ? 'disabled' : ''}`;
    nextLi.innerHTML = `<a class="page-link" href="#" onclick="loadBooks(${data.number + 1}, '${currentSearchTerm}')">下一页</a>`;
    pagination.appendChild(nextLi);
}

// 快速搜索
function quickSearch() {
    const searchTerm = document.getElementById('quickSearchInput').value.trim();
    currentSearchTerm = searchTerm;
    loadBooks(0, searchTerm);
}

// 高级搜索
async function advancedSearch() {
    const title = document.getElementById('searchTitle').value.trim();
    const author = document.getElementById('searchAuthor').value.trim();
    const publisher = document.getElementById('searchPublisher').value.trim();
    const isbn = document.getElementById('searchIsbn').value.trim();

    const token = localStorage.getItem('token');
    const params = new URLSearchParams();
    
    if (title) params.append('title', title);
    if (author) params.append('author', author);
    if (publisher) params.append('publisher', publisher);
    if (isbn) params.append('isbn', isbn);
    params.append('page', '0');
    params.append('size', '12');

    try {
        const response = await fetch(`${API_BASE_URL}/books/search?${params.toString()}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (response.ok) {
            const data = await response.json();
            displaySearchResults(data.content);
            document.getElementById('totalBooks').textContent = data.totalElements;
        } else {
            alert('搜索失败');
        }
    } catch (error) {
        alert('搜索失败: ' + error.message);
    }
}

// 显示搜索结果
function displaySearchResults(books) {
    const searchResults = document.getElementById('searchResults');
    searchResults.innerHTML = '<h5>搜索结果</h5>';
    
    if (books.length === 0) {
        searchResults.innerHTML += '<div class="alert alert-info">没有找到匹配的图书</div>';
        return;
    }

    const row = document.createElement('div');
    row.className = 'row';
    
    books.forEach(book => {
        const bookCard = createBookCard(book);
        row.appendChild(bookCard);
    });
    
    searchResults.appendChild(row);
}

// 清空搜索
function clearSearch() {
    document.getElementById('searchTitle').value = '';
    document.getElementById('searchAuthor').value = '';
    document.getElementById('searchPublisher').value = '';
    document.getElementById('searchIsbn').value = '';
    document.getElementById('searchResults').innerHTML = '';
}

// 添加图书
async function addBook() {
    const token = localStorage.getItem('token');
    
    const book = {
        isbn: document.getElementById('bookIsbn').value,
        title: document.getElementById('bookTitle').value,
        author: document.getElementById('bookAuthor').value,
        publisher: document.getElementById('bookPublisher').value,
        publishYear: parseInt(document.getElementById('bookYear').value),
        price: parseFloat(document.getElementById('bookPrice').value),
        stockQuantity: parseInt(document.getElementById('bookStock').value),
        description: document.getElementById('bookDescription').value
    };

    try {
        const response = await fetch(`${API_BASE_URL}/books`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(book)
        });

        if (response.ok) {
            alert('图书添加成功！');
            document.getElementById('addBookForm').reset();
            showPage('booksPage');
            loadBooks();
        } else {
            const error = await response.text();
            alert('添加图书失败: ' + error);
        }
    } catch (error) {
        alert('添加图书失败: ' + error.message);
    }
}

// 编辑图书（简化版本，实际应用中需要更复杂的实现）
function editBook(bookId) {
    // 这里简化处理，实际应用中应该打开编辑表单
    alert('编辑功能需要更复杂的实现，图书ID: ' + bookId);
}

// 删除图书
async function deleteBook(bookId) {
    if (!confirm('确定要删除这本图书吗？')) {
        return;
    }

    const token = localStorage.getItem('token');

    try {
        const response = await fetch(`${API_BASE_URL}/books/${bookId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (response.ok) {
            alert('图书删除成功！');
            loadBooks();
        } else {
            const error = await response.text();
            alert('删除图书失败: ' + error);
        }
    } catch (error) {
        alert('删除图书失败: ' + error.message);
    }
}