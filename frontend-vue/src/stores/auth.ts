import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/api/auth'
import { ElMessage } from 'element-plus'
import { type LoginForm, type User } from '@/types/auth'
import Cookies from 'js-cookie'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const loading = ref(false)

  // 计算属性
  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const isAdmin = computed(() => user.value?.role === 'ADMIN')
  const userName = computed(() => user.value?.username || '')

  // 登录
  const login = async (loginForm: LoginForm) => {
    loading.value = true
    try {
      const response = await authApi.login(loginForm)
      
      // 验证响应数据
      if (!response.data || !response.data.token || !response.data.user) {
        throw new Error('登录响应数据不完整')
      }
      
      // 保存认证信息
      token.value = response.data.token
      user.value = response.data.user
      
      // 保存到本地存储
      Cookies.set('token', response.data.token, { expires: 7 })
      localStorage.setItem('user', JSON.stringify(response.data.user))
      
      ElMessage.success('登录成功')
      return response.data
    } catch (error: any) {
      console.error('登录失败:', error)
      
      // 根据错误类型显示不同提示
      if (error.response) {
        if (error.response.status === 401) {
          ElMessage.error('用户名或密码错误')
        } else if (error.response.status === 403) {
          ElMessage.error('账户被禁用，请联系管理员')
        } else {
          ElMessage.error(error.response.data?.message || '登录失败，请重试')
        }
      } else if (error.request) {
        ElMessage.error('网络连接失败，请检查网络后重试')
      } else {
        ElMessage.error(error.message || '登录过程中发生错误，请重试')
      }
      
      throw error
    } finally {
      loading.value = false
    }
  }

  // 登出
  const logout = () => {
    user.value = null
    token.value = null
    
    // 清除本地存储
    Cookies.remove('token')
    localStorage.removeItem('user')
    
    ElMessage.success('已成功退出登录')
  }

  // 从本地存储恢复认证状态
  const restoreAuth = () => {
    const savedToken = Cookies.get('token')
    const savedUser = localStorage.getItem('user')
    
    if (savedToken && savedUser) {
      try {
        token.value = savedToken
        user.value = JSON.parse(savedUser)
      } catch (error) {
        console.error('恢复认证状态失败:', error)
        logout()
      }
    }
  }

  return {
    user,
    token,
    loading,
    isAuthenticated,
    isAdmin,
    userName,
    login,
    logout,
    restoreAuth
  }
})