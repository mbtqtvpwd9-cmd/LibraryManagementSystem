export interface User {
  id: number
  username: string
  email: string
  role: 'ADMIN' | 'READER'
  avatar?: string
  phone?: string
  createdAt?: string
  updatedAt?: string
  status?: 'ACTIVE' | 'INACTIVE'
}

export interface LoginForm {
  username: string
  password: string
  role: 'ADMIN' | 'READER'
}

export interface RegisterForm {
  username: string
  password: string
  email: string
  role: 'ADMIN' | 'READER'
  phone?: string
}

export interface LoginResponse {
  token: string
  type: string
  user: User
}