import axios from 'axios'
import { useAuthStore } from '@/stores/auth'
import { type LoginForm, type RegisterForm, type LoginResponse } from '@/types/auth'

// 创建axios实例
const request = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
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
    const authStore = useAuthStore()
    
    // 处理401错误
    if (error.response?.status === 401) {
      authStore.logout()
      // 跳转到登录页
      window.location.href = '/login'
    }
    
    return Promise.reject(error)
  }
)

export const authApi = {
  // 登录
  login: (data: LoginForm) => request.post<LoginResponse>('/auth/login', data),
  
  // 注册
  register: (data: RegisterForm) => request.post('/auth/register', data),
  
  // 获取当前用户信息
  getCurrentUser: () => request.get('/auth/me'),
  
  // 刷新token
  refreshToken: () => request.post('/auth/refresh')
}