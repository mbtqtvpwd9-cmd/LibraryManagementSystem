<template>
  <div class="dashboard-container">
    <div class="page-header">
      <h1>仪表盘</h1>
      <p>欢迎使用智慧图书管理系统</p>
    </div>
    
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#409EFF">
                <Reading />
              </el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.totalBooks }}</div>
              <div class="stat-label">图书总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#67C23A">
                <User />
              </el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.totalUsers }}</div>
              <div class="stat-label">用户总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#E6A23C">
                <Collection />
              </el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.borrowedBooks }}</div>
              <div class="stat-label">已借出</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon size="32" color="#F56C6C">
                <Warning />
              </el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.overdueBooks }}</div>
              <div class="stat-label">逾期未还</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" class="content-row">
      <el-col :span="16">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>最近活动</span>
            </div>
          </template>
          <el-table :data="recentActivities" style="width: 100%">
            <el-table-column prop="user" label="用户" width="120" />
            <el-table-column prop="action" label="操作" />
            <el-table-column prop="target" label="对象" />
            <el-table-column prop="time" label="时间" width="180" />
          </el-table>
        </el-card>
      </el-col>
      
      <el-col :span="8">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>系统信息</span>
            </div>
          </template>
          <div class="system-info">
            <div class="info-item">
              <span class="info-label">系统版本：</span>
              <span class="info-value">v1.0.0</span>
            </div>
            <div class="info-item">
              <span class="info-label">数据库状态：</span>
              <el-tag type="success">正常</el-tag>
            </div>
            <div class="info-item">
              <span class="info-label">最后更新：</span>
              <span class="info-value">{{ lastUpdateTime }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Reading, User, Collection, Warning } from '@element-plus/icons-vue'
import api from '@/api'

// 统计数据
const stats = ref({
  totalBooks: 0,
  totalUsers: 0,
  borrowedBooks: 0,
  overdueBooks: 0
})

// 最近活动
const recentActivities = ref([
  { user: 'admin', action: '添加', target: '《Java编程思想》', time: '2023-11-28 14:30:00' },
  { user: 'reader', action: '借阅', target: '《设计模式》', time: '2023-11-28 13:45:00' },
  { user: 'admin', action: '更新', target: '《算法导论》', time: '2023-11-28 11:20:00' },
  { user: 'reader', action: '归还', target: '《重构》', time: '2023-11-28 10:15:00' }
])

// 最后更新时间
const lastUpdateTime = ref('2023-11-28 15:00:00')

// 加载统计数据
const loadStats = async () => {
  try {
    // 这里应该调用实际的API
    // const response = await api.get('/stats')
    // stats.value = response.data
    
    // 模拟数据
    stats.value = {
      totalBooks: 1250,
      totalUsers: 320,
      borrowedBooks: 158,
      overdueBooks: 12
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败')
  }
}

// 更新最后更新时间
const updateLastTime = () => {
  const now = new Date()
  lastUpdateTime.value = now.toLocaleString('zh-CN')
}

onMounted(() => {
  loadStats()
  updateLastTime()
})
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
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

.stats-row {
  margin-bottom: 24px;
}

.stat-card {
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  align-items: center;
}

.stat-icon {
  margin-right: 16px;
}

.stat-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #606266;
}

.content-row {
  margin-top: 24px;
}

.card-header {
  font-weight: 500;
}

.system-info {
  padding: 8px 0;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #EBEEF5;
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  color: #606266;
}

.info-value {
  color: #303133;
}
</style>