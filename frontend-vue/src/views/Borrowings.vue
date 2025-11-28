<template>
  <div class="borrowings-container">
    <div class="page-header">
      <div class="header-left">
        <h1>借阅管理</h1>
        <p>管理所有图书的借阅记录</p>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="showBorrowDialog = true">
          <el-icon><Plus /></el-icon>
          添加借阅
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="借阅人">
          <el-input v-model="searchForm.userName" placeholder="请输入借阅人" clearable />
        </el-form-item>
        <el-form-item label="图书">
          <el-input v-model="searchForm.bookTitle" placeholder="请输入图书名称" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="借阅中" value="BORROWED" />
            <el-option label="已归还" value="RETURNED" />
            <el-option label="逾期" value="OVERDUE" />
          </el-select>
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
      <el-table :data="borrowings" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="userName" label="借阅人" width="120" />
        <el-table-column prop="bookTitle" label="图书名称" />
        <el-table-column prop="borrowDate" label="借阅日期" width="120" />
        <el-table-column prop="returnDate" label="应还日期" width="120" />
        <el-table-column prop="actualReturnDate" label="实际归还日期" width="130" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag
              :type="getStatusType(scope.row.status)"
            >
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <el-button
              v-if="scope.row.status === 'BORROWED'"
              size="small"
              type="success"
              link
              @click="handleReturn(scope.row)"
            >
              <el-icon><Check /></el-icon>
              归还
            </el-button>
            <el-button
              v-if="scope.row.status === 'BORROWED'"
              size="small"
              type="warning"
              link
              @click="handleRenew(scope.row)"
            >
              <el-icon><Refresh /></el-icon>
              续借
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

    <!-- 添加借阅对话框 -->
    <el-dialog
      v-model="showBorrowDialog"
      title="添加借阅"
      width="500px"
      @close="resetForm"
    >
      <el-form
        ref="borrowFormRef"
        :model="borrowForm"
        :rules="borrowRules"
        label-width="100px"
      >
        <el-form-item label="借阅人" prop="userId">
          <el-select v-model="borrowForm.userId" placeholder="请选择借阅人" style="width: 100%">
            <el-option
              v-for="user in users"
              :key="user.id"
              :label="user.username"
              :value="user.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="图书" prop="bookId">
          <el-select v-model="borrowForm.bookId" placeholder="请选择图书" style="width: 100%">
            <el-option
              v-for="book in availableBooks"
              :key="book.id"
              :label="book.title"
              :value="book.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="借阅天数" prop="borrowDays">
          <el-input-number v-model="borrowForm.borrowDays" :min="1" :max="30" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showBorrowDialog = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { Plus, Search, Check, Refresh, Delete } from '@element-plus/icons-vue'
import api from '@/api'

// 借阅记录数据
const borrowings = ref<any[]>([])
const loading = ref(false)

// 用户列表
const users = ref<any[]>([])

// 可借阅图书列表
const availableBooks = ref<any[]>([])

// 分页数据
const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

// 搜索表单
const searchForm = reactive({
  userName: '',
  bookTitle: '',
  status: ''
})

// 添加借阅对话框
const showBorrowDialog = ref(false)
const borrowFormRef = ref<FormInstance>()

// 借阅表单
const borrowForm = reactive({
  userId: null,
  bookId: null,
  borrowDays: 7
})

// 表单验证规则
const borrowRules: FormRules = {
  userId: [
    { required: true, message: '请选择借阅人', trigger: 'change' }
  ],
  bookId: [
    { required: true, message: '请选择图书', trigger: 'change' }
  ],
  borrowDays: [
    { required: true, message: '请选择借阅天数', trigger: 'change' }
  ]
}

// 获取状态类型
const getStatusType = (status: string) => {
  switch (status) {
    case 'BORROWED': return 'primary'
    case 'RETURNED': return 'success'
    case 'OVERDUE': return 'danger'
    default: return ''
  }
}

// 获取状态文本
const getStatusText = (status: string) => {
  switch (status) {
    case 'BORROWED': return '借阅中'
    case 'RETURNED': return '已归还'
    case 'OVERDUE': return '逾期'
    default: return '未知'
  }
}

// 加载借阅记录
const loadBorrowings = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {
      page: pagination.page - 1,
      size: pagination.size,
      ...searchForm
    }
    
    // 这里应该调用实际的API
    // const response = await api.get('/borrowings', { params })
    
    // 模拟数据
    const mockBorrowings = Array.from({ length: 20 }, (_, index) => {
      const status = ['BORROWED', 'RETURNED', 'OVERDUE'][Math.floor(Math.random() * 3)]
      const borrowDate = new Date()
      borrowDate.setDate(borrowDate.getDate() - Math.floor(Math.random() * 30))
      
      let returnDate = new Date(borrowDate)
      returnDate.setDate(returnDate.getDate() + 14)
      
      let actualReturnDate = null
      if (status === 'RETURNED') {
        actualReturnDate = new Date(borrowDate)
        actualReturnDate.setDate(actualReturnDate.getDate() + Math.floor(Math.random() * 14))
      }
      
      return {
        id: index + 1,
        userName: `用户${index + 1}`,
        bookTitle: `图书标题 ${index + 1}`,
        borrowDate: borrowDate.toISOString().split('T')[0],
        returnDate: returnDate.toISOString().split('T')[0],
        actualReturnDate: actualReturnDate ? actualReturnDate.toISOString().split('T')[0] : '',
        status
      }
    })
    
    borrowings.value = mockBorrowings
    pagination.total = 100 // 模拟总数
  } catch (error) {
    console.error('加载借阅记录失败:', error)
    ElMessage.error('加载借阅记录失败')
  } finally {
    loading.value = false
  }
}

// 加载用户列表
const loadUsers = async () => {
  try {
    // 这里应该调用实际的API
    // const response = await api.get('/users')
    
    // 模拟数据
    users.value = Array.from({ length: 10 }, (_, index) => ({
      id: index + 1,
      username: `用户${index + 1}`
    }))
  } catch (error) {
    console.error('加载用户列表失败:', error)
  }
}

// 加载可借阅图书列表
const loadAvailableBooks = async () => {
  try {
    // 这里应该调用实际的API
    // const response = await api.get('/books/available')
    
    // 模拟数据
    availableBooks.value = Array.from({ length: 10 }, (_, index) => ({
      id: index + 1,
      title: `图书标题 ${index + 1}`
    }))
  } catch (error) {
    console.error('加载图书列表失败:', error)
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadBorrowings()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

// 归还
const handleReturn = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定这本书已归还吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'info'
    })
    
    // 这里应该调用实际的API
    // await api.post(`/borrowings/${row.id}/return`)
    
    ElMessage.success('归还成功')
    loadBorrowings()
  } catch (error) {
    console.error('归还失败:', error)
  }
}

// 续借
const handleRenew = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要续借这本书吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'info'
    })
    
    // 这里应该调用实际的API
    // await api.post(`/borrowings/${row.id}/renew`)
    
    ElMessage.success('续借成功')
    loadBorrowings()
  } catch (error) {
    console.error('续借失败:', error)
  }
}

// 删除借阅记录
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要删除这条借阅记录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    // 这里应该调用实际的API
    // await api.delete(`/borrowings/${row.id}`)
    
    ElMessage.success('删除成功')
    loadBorrowings()
  } catch (error) {
    console.error('删除失败:', error)
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!borrowFormRef.value) return
  
  try {
    await borrowFormRef.value.validate()
    
    // 这里应该调用实际的API
    // await api.post('/borrowings', borrowForm)
    
    ElMessage.success('添加借阅成功')
    showBorrowDialog.value = false
    loadBorrowings()
  } catch (error) {
    console.error('提交失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (borrowFormRef.value) {
    borrowFormRef.value.resetFields()
  }
  
  borrowForm.userId = null
  borrowForm.bookId = null
  borrowForm.borrowDays = 7
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.size = size
  pagination.page = 1
  loadBorrowings()
}

// 页码改变
const handleCurrentChange = (page: number) => {
  pagination.page = page
  loadBorrowings()
}

onMounted(() => {
  loadBorrowings()
  loadUsers()
  loadAvailableBooks()
})
</script>

<style scoped>
.borrowings-container {
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