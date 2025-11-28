<template>
  <div class="users-container">
    <div class="page-header">
      <div class="header-left">
        <h1>用户管理</h1>
        <p>管理所有系统用户</p>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="showAddDialog = true">
          <el-icon><Plus /></el-icon>
          添加用户
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="用户名">
          <el-input v-model="searchForm.username" placeholder="请输入用户名" clearable />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="searchForm.role" placeholder="请选择角色" clearable>
            <el-option label="管理员" value="ADMIN" />
            <el-option label="读者" value="READER" />
          </el-select>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="searchForm.email" placeholder="请输入邮箱" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <el-table :data="users" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="role" label="角色" width="120">
          <template #default="scope">
            <el-tag :type="scope.row.role === 'ADMIN' ? 'danger' : 'primary'">
              {{ scope.row.role === 'ADMIN' ? '管理员' : '读者' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <el-button size="small" type="primary" link @click="handleEdit(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button 
              size="small" 
              :type="scope.row.enabled ? 'warning' : 'success'" 
              link 
              @click="handleToggleStatus(scope.row)"
            >
              <el-icon>
                <Lock v-if="scope.row.enabled" />
                <Unlock v-else />
              </el-icon>
              {{ scope.row.enabled ? '禁用' : '启用' }}
            </el-button>
            <el-button size="small" type="danger" link @click="handleDelete(scope.row)">
              <el-icon><Delete /></el-icon>
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 添加/编辑对话框 -->
    <el-dialog
      v-model="showAddDialog"
      :title="isEdit ? '编辑用户' : '添加用户'"
      width="500px"
      @close="resetForm"
    >
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userRules"
        label-width="80px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input 
            v-model="userForm.password" 
            type="password" 
            placeholder="请输入密码"
            show-password 
          />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="管理员" value="ADMIN" />
            <el-option label="读者" value="READER" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="enabled" v-if="isEdit">
          <el-switch v-model="userForm.enabled" active-text="启用" inactive-text="禁用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { Plus, Search, Edit, Delete, Lock, Unlock } from '@element-plus/icons-vue'
import api from '@/api'

// 用户数据
const users = ref<any[]>([])
const loading = ref(false)

// 分页数据
const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

// 搜索表单
const searchForm = reactive({
  username: '',
  role: '',
  email: ''
})

// 添加/编辑对话框
const showAddDialog = ref(false)
const isEdit = ref(false)
const userFormRef = ref<FormInstance>()

// 用户表单
const userForm = reactive({
  id: null,
  username: '',
  password: '',
  email: '',
  role: 'READER',
  enabled: true
})

// 表单验证规则
const userRules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在3-20个字符之间', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

// 格式化日期
const formatDate = (date: string) => {
  if (!date) return '-'
  const d = new Date(date)
  return d.toLocaleString('zh-CN')
}

// 加载用户数据
const loadUsers = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {
      page: pagination.page - 1,
      size: pagination.size,
      ...searchForm
    }
    
    // 这里应该调用实际的API
    // const response = await api.get('/users', { params })
    
    // 模拟数据
    const mockUsers = Array.from({ length: 20 }, (_, index) => {
      const isAdmin = index < 5 // 前五个为管理员
      return {
        id: index + 1,
        username: `${isAdmin ? 'admin' : 'user'}${index + 1}`,
        email: `${isAdmin ? 'admin' : 'user'}${index + 1}@example.com`,
        role: isAdmin ? 'ADMIN' : 'READER',
        enabled: Math.random() > 0.2, // 80%概率为启用状态
        createdAt: new Date(Date.now() - Math.floor(Math.random() * 365 * 24 * 60 * 60 * 1000)).toISOString()
      }
    })
    
    users.value = mockUsers
    pagination.total = 100 // 模拟总数
  } catch (error) {
    console.error('加载用户数据失败:', error)
    ElMessage.error('加载用户数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadUsers()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

// 编辑用户
const handleEdit = (row: any) => {
  isEdit.value = true
  showAddDialog.value = true
  Object.assign(userForm, row)
}

// 切换用户状态
const handleToggleStatus = async (row: any) => {
  try {
    const action = row.enabled ? '禁用' : '启用'
    await ElMessageBox.confirm(`确定要${action}用户 ${row.username} 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    // 这里应该调用实际的API
    // await api.patch(`/users/${row.id}/status`, { enabled: !row.enabled })
    
    ElMessage.success(`${action}成功`)
    loadUsers()
  } catch (error) {
    console.error('切换用户状态失败:', error)
  }
}

// 删除用户
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确定要删除用户 ${row.username} 吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    // 这里应该调用实际的API
    // await api.delete(`/users/${row.id}`)
    
    ElMessage.success('删除成功')
    loadUsers()
  } catch (error) {
    console.error('删除用户失败:', error)
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!userFormRef.value) return
  
  try {
    await userFormRef.value.validate()
    
    if (isEdit.value) {
      // 编辑
      // await api.put(`/users/${userForm.id}`, userForm)
      ElMessage.success('编辑成功')
    } else {
      // 添加
      // await api.post('/users', userForm)
      ElMessage.success('添加成功')
    }
    
    showAddDialog.value = false
    loadUsers()
  } catch (error) {
    console.error('提交失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (userFormRef.value) {
    userFormRef.value.resetFields()
  }
  
  userForm.id = null
  userForm.username = ''
  userForm.password = ''
  userForm.email = ''
  userForm.role = 'READER'
  userForm.enabled = true
  isEdit.value = false
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.size = size
  pagination.page = 1
  loadUsers()
}

// 页码改变
const handleCurrentChange = (page: number) => {
  pagination.page = page
  loadUsers()
}

onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.users-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0 0 8px 0;
  font-size: 24px;
  color: #303133;
}

.page-header p {
  margin: 0;
  color: #606266;
}

.search-card {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>