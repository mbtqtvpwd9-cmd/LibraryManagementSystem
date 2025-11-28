<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h1>智慧图书管理系统</h1>
        <p>请使用您的账户登录系统</p>
      </div>
      <div class="login-body">
        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          label-width="80px"
          size="large"
          @submit.prevent="handleLogin"
        >
          <el-form-item label="用户名" prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="请输入用户名"
              prefix-icon="User"
            />
          </el-form-item>
          
          <el-form-item label="密码" prop="password">
            <el-input
              v-model="loginForm.password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="请输入密码"
              prefix-icon="Lock"
            >
              <template #suffix>
                <el-icon
                  class="cursor-pointer"
                  @click="showPassword = !showPassword"
                >
                  <View v-if="showPassword" />
                  <Hide v-else />
                </el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item label="角色" prop="role">
            <el-select v-model="loginForm.role" placeholder="请选择角色" style="width: 100%">
              <el-option label="管理员" value="ADMIN" />
              <el-option label="读者" value="READER" />
            </el-select>
          </el-form-item>
          
          <el-form-item>
            <el-button
              type="primary"
              :loading="authStore.loading"
              style="width: 100%"
              @click="handleLogin"
            >
              登录
            </el-button>
          </el-form-item>
        </el-form>
        
        <div class="login-tips">
          <p>默认管理员账号：admin/admin123</p>
          <p>默认读者账号：reader/reader123</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { User, Lock, View, Hide } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import type { LoginForm } from '@/types/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const loginFormRef = ref<FormInstance>()

// 表单数据
const loginForm = reactive<LoginForm>({
  username: '',
  password: '',
  role: 'ADMIN'
})

// 是否显示密码
const showPassword = ref(false)

// 表单验证规则
const loginRules: FormRules<LoginForm> = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

// 登录处理
const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    await authStore.login(loginForm)
    
    // 登录成功，跳转到目标页面
    const redirect = route.query.redirect as string || '/dashboard'
    router.push(redirect)
  } catch (error) {
    console.error('登录失败:', error)
  }
}

// 组件挂载时，检查是否已登录
onMounted(() => {
  if (authStore.isAuthenticated) {
    router.push('/dashboard')
  }
})
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 450px;
  overflow: hidden;
}

.login-header {
  background: linear-gradient(135deg, #2c3e50, #3498db);
  color: white;
  padding: 40px 30px;
  text-align: center;
}

.login-header h1 {
  font-weight: 700;
  margin-bottom: 10px;
  font-size: 2rem;
}

.login-header p {
  opacity: 0.9;
  margin: 0;
}

.login-body {
  padding: 40px 30px;
}

.login-tips {
  margin-top: 20px;
  text-align: center;
  font-size: 0.9rem;
  color: #666;
}

.login-tips p {
  margin: 5px 0;
}

.cursor-pointer {
  cursor: pointer;
}
</style>