import axios from 'axios'
import { type Book, type BookQuery, type BookResponse, type BookForm } from '@/types/book'

// 创建axios实例
const request = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    // 处理401错误
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    
    return Promise.reject(error)
  }
)

export const bookApi = {
  // 获取图书列表
  getBooks: (query?: BookQuery) => {
    const params = new URLSearchParams()
    
    if (query) {
      Object.keys(query).forEach(key => {
        const value = query[key as keyof BookQuery]
        if (value !== undefined && value !== null && value !== '') {
          params.append(key, String(value))
        }
      })
    }
    
    return request.get<BookResponse>(`/books?${params.toString()}`)
  },
  
  // 获取图书详情
  getBookById: (id: number) => request.get<Book>(`/books/${id}`),
  
  // 根据ISBN获取图书
  getBookByIsbn: (isbn: string) => request.get<Book>(`/books/isbn/${isbn}`),
  
  // 创建图书
  createBook: (data: BookForm) => request.post<Book>('/books', data),
  
  // 更新图书
  updateBook: (id: number, data: Partial<Book>) => request.put<Book>(`/books/${id}`, data),
  
  // 删除图书
  deleteBook: (id: number) => request.delete(`/books/${id}`),
  
  // 搜索图书
  searchBooks: (query: BookQuery) => {
    const params = new URLSearchParams()
    
    Object.keys(query).forEach(key => {
      const value = query[key as keyof BookQuery]
      if (value !== undefined && value !== null && value !== '') {
        params.append(key, String(value))
      }
    })
    
    return request.get<BookResponse>(`/books/search?${params.toString()}`)
  },
  
  // 按书名搜索
  searchBooksByTitle: (title: string) => request.get<Book[]>(`/books/search/title?title=${title}`),
  
  // 按作者搜索
  searchBooksByAuthor: (author: string) => request.get<Book[]>(`/books/search/author?author=${author}`),
  
  // 按出版社搜索
  searchBooksByPublisher: (publisher: string) => request.get<Book[]>(`/books/search/publisher?publisher=${publisher}`),
  
  // 获取图书总数
  getBookCount: () => request.get<number>('/books/count')
}