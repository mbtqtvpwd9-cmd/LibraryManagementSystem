// 认证相关的类型定义

export interface LoginForm {
  username: string
  password: string
  role: 'ADMIN' | 'READER'
}

export interface User {
  id: number
  username: string
  email?: string
  role: 'ADMIN' | 'READER'
}

export interface LoginResponse {
  token: string
  type: string
  user: User
}