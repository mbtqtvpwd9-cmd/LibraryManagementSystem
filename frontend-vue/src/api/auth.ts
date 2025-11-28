import axios from 'axios'
import type { LoginForm, LoginResponse, User } from '@/types/auth'

// 创建axios实例
const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器 - 添加token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token') || sessionStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器 - 统一处理错误
api.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    // 处理401未授权错误
    if (error.response && error.response.status === 401) {
      // 清除本地存储的token
      localStorage.removeItem('token')
      sessionStorage.removeItem('token')
      localStorage.removeItem('user')
      
      // 跳转到登录页
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export const authApi = {
  // 登录
  login: (data: LoginForm) => api.post<LoginResponse>('/auth/login', data),
  
  // 注册
  register: (data: any) => api.post('/auth/register', data),
  
  // 获取当前用户信息
  getCurrentUser: () => api.get<User>('/auth/me'),
  
  // 登出
  logout: () => api.post('/auth/logout')
}

export default api