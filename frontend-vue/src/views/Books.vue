<template>
  <div class="books-container">
    <div class="page-header">
      <div class="header-left">
        <h1>图书管理</h1>
        <p>管理系统中的所有图书信息</p>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="showAddDialog = true">
          <el-icon><Plus /></el-icon>
          添加图书
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="书名">
          <el-input v-model="searchForm.title" placeholder="请输入书名" clearable />
        </el-form-item>
        <el-form-item label="作者">
          <el-input v-model="searchForm.author" placeholder="请输入作者" clearable />
        </el-form-item>
        <el-form-item label="ISBN">
          <el-input v-model="searchForm.isbn" placeholder="请输入ISBN" clearable />
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
      <el-table :data="books" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="isbn" label="ISBN" width="150" />
        <el-table-column prop="title" label="书名" />
        <el-table-column prop="author" label="作者" width="150" />
        <el-table-column prop="publisher" label="出版社" width="150" />
        <el-table-column prop="publishYear" label="出版年份" width="120" />
        <el-table-column prop="price" label="价格" width="100">
          <template #default="scope">
            ¥{{ scope.row.price }}
          </template>
        </el-table-column>
        <el-table-column prop="stockQuantity" label="库存" width="100" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="scope">
            <el-button size="small" type="primary" link @click="handleEdit(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
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
      :title="isEdit ? '编辑图书' : '添加图书'"
      width="600px"
      @close="resetForm"
    >
      <el-form
        ref="bookFormRef"
        :model="bookForm"
        :rules="bookRules"
        label-width="100px"
      >
        <el-form-item label="ISBN" prop="isbn">
          <el-input v-model="bookForm.isbn" placeholder="请输入ISBN" />
        </el-form-item>
        <el-form-item label="书名" prop="title">
          <el-input v-model="bookForm.title" placeholder="请输入书名" />
        </el-form-item>
        <el-form-item label="作者" prop="author">
          <el-input v-model="bookForm.author" placeholder="请输入作者" />
        </el-form-item>
        <el-form-item label="出版社" prop="publisher">
          <el-input v-model="bookForm.publisher" placeholder="请输入出版社" />
        </el-form-item>
        <el-form-item label="出版年份" prop="publishYear">
          <el-input-number v-model="bookForm.publishYear" :min="1900" :max="2100" />
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input-number v-model="bookForm.price" :min="0" :precision="2" />
        </el-form-item>
        <el-form-item label="库存数量" prop="stockQuantity">
          <el-input-number v-model="bookForm.stockQuantity" :min="0" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="bookForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入图书描述"
          />
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
import { Plus, Search, Edit, Delete } from '@element-plus/icons-vue'
import api from '@/api'

// 图书数据
const books = ref<any[]>([])
const loading = ref(false)

// 分页数据
const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

// 搜索表单
const searchForm = reactive({
  title: '',
  author: '',
  isbn: ''
})

// 添加/编辑对话框
const showAddDialog = ref(false)
const isEdit = ref(false)
const bookFormRef = ref<FormInstance>()

// 图书表单
const bookForm = reactive({
  id: null,
  isbn: '',
  title: '',
  author: '',
  publisher: '',
  publishYear: new Date().getFullYear(),
  price: 0,
  stockQuantity: 0,
  description: ''
})

// 表单验证规则
const bookRules: FormRules = {
  isbn: [
    { required: true, message: '请输入ISBN', trigger: 'blur' }
  ],
  title: [
    { required: true, message: '请输入书名', trigger: 'blur' }
  ],
  author: [
    { required: true, message: '请输入作者', trigger: 'blur' }
  ],
  publisher: [
    { required: true, message: '请输入出版社', trigger: 'blur' }
  ],
  publishYear: [
    { required: true, message: '请选择出版年份', trigger: 'change' }
  ],
  price: [
    { required: true, message: '请输入价格', trigger: 'blur' }
  ],
  stockQuantity: [
    { required: true, message: '请输入库存数量', trigger: 'blur' }
  ]
}

// 加载图书数据
const loadBooks = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {
      page: pagination.page - 1,
      size: pagination.size,
      ...searchForm
    }
    
    // 这里应该调用实际的API
    // const response = await api.get('/books', { params })
    
    // 模拟数据
    const mockBooks = Array.from({ length: 20 }, (_, index) => ({
      id: index + 1,
      isbn: `978-7-${Math.floor(Math.random() * 10000000000)}`,
      title: `图书标题 ${index + 1}`,
      author: `作者名 ${index + 1}`,
      publisher: `出版社 ${index + 1}`,
      publishYear: 2020 + (index % 4),
      price: Math.floor(Math.random() * 100) + 10,
      stockQuantity: Math.floor(Math.random() * 100),
      description: `这是图书 ${index + 1} 的描述信息`
    }))
    
    books.value = mockBooks
    pagination.total = 100 // 模拟总数
  } catch (error) {
    console.error('加载图书数据失败:', error)
    ElMessage.error('加载图书数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadBooks()
}

// 重置搜索
const resetSearch = () => {
  Object.keys(searchForm).forEach(key => {
    searchForm[key] = ''
  })
  handleSearch()
}

// 编辑图书
const handleEdit = (row: any) => {
  isEdit.value = true
  showAddDialog.value = true
  Object.assign(bookForm, row)
}

// 删除图书
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要删除这本书吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    // 这里应该调用实际的API
    // await api.delete(`/books/${row.id}`)
    
    ElMessage.success('删除成功')
    loadBooks()
  } catch (error) {
    console.error('删除图书失败:', error)
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!bookFormRef.value) return
  
  try {
    await bookFormRef.value.validate()
    
    if (isEdit.value) {
      // 编辑
      // await api.put(`/books/${bookForm.id}`, bookForm)
      ElMessage.success('编辑成功')
    } else {
      // 添加
      // await api.post('/books', bookForm)
      ElMessage.success('添加成功')
    }
    
    showAddDialog.value = false
    loadBooks()
  } catch (error) {
    console.error('提交失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (bookFormRef.value) {
    bookFormRef.value.resetFields()
  }
  
  bookForm.id = null
  bookForm.isbn = ''
  bookForm.title = ''
  bookForm.author = ''
  bookForm.publisher = ''
  bookForm.publishYear = new Date().getFullYear()
  bookForm.price = 0
  bookForm.stockQuantity = 0
  bookForm.description = ''
  isEdit.value = false
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.size = size
  pagination.page = 1
  loadBooks()
}

// 页码改变
const handleCurrentChange = (page: number) => {
  pagination.page = page
  loadBooks()
}

onMounted(() => {
  loadBooks()
})
</script>

<style scoped>
.books-container {
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