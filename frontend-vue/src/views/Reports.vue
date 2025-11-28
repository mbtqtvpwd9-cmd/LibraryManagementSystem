<template>
  <div class="reports-container">
    <div class="page-header">
      <div class="header-left">
        <h1>统计报表</h1>
        <p>查看各类统计数据分析</p>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="handleExport">
          <el-icon><Download /></el-icon>
          导出报表
        </el-button>
      </div>
    </div>

    <el-row :gutter="20">
      <!-- 借阅统计 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>借阅统计</span>
              <el-select v-model="borrowChartPeriod" size="small" style="width: 120px">
                <el-option label="本月" value="month" />
                <el-option label="本季度" value="quarter" />
                <el-option label="本年" value="year" />
              </el-select>
            </div>
          </template>
          <div class="chart-container">
            <div ref="borrowChartRef" class="chart"></div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 图书分类统计 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>图书分类统计</span>
              <el-select v-model="categoryChartType" size="small" style="width: 120px">
                <el-option label="饼图" value="pie" />
                <el-option label="环形图" value="donut" />
              </el-select>
            </div>
          </template>
          <div class="chart-container">
            <div ref="categoryChartRef" class="chart"></div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <!-- 读者活跃度 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>读者活跃度</span>
              <el-radio-group v-model="readerActivityPeriod" size="small">
                <el-radio-button label="week">本周</el-radio-button>
                <el-radio-button label="month">本月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div class="chart-container">
            <div ref="readerActivityChartRef" class="chart"></div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 热门图书 -->
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>热门图书 TOP10</span>
            </div>
          </template>
          <el-table :data="hotBooks" style="width: 100%" height="300">
            <el-table-column type="index" label="排名" width="60" />
            <el-table-column prop="title" label="书名" />
            <el-table-column prop="borrowCount" label="借阅次数" width="100" />
            <el-table-column prop="author" label="作者" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <!-- 数据汇总 -->
    <el-card class="summary-card" style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>数据汇总</span>
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            size="small"
            style="width: 240px"
            @change="loadSummary"
          />
        </div>
      </template>
      <el-row :gutter="20">
        <el-col :span="6">
          <div class="summary-item">
            <div class="summary-label">新增图书</div>
            <div class="summary-value">{{ summary.newBooks }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="summary-item">
            <div class="summary-label">新增用户</div>
            <div class="summary-value">{{ summary.newUsers }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="summary-item">
            <div class="summary-label">总借阅次数</div>
            <div class="summary-value">{{ summary.totalBorrowings }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="summary-item">
            <div class="summary-label">逾期未还</div>
            <div class="summary-value">{{ summary.overdueBooks }}</div>
          </div>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Download } from '@element-plus/icons-vue'
import * as echarts from 'echarts'

// 图表引用
const borrowChartRef = ref<HTMLElement>()
const categoryChartRef = ref<HTMLElement>()
const readerActivityChartRef = ref<HTMLElement>()

// 图表实例
let borrowChartInstance: echarts.ECharts | null = null
let categoryChartInstance: echarts.ECharts | null = null
let readerActivityChartInstance: echarts.ECharts | null = null

// 图表参数
const borrowChartPeriod = ref('month')
const categoryChartType = ref('pie')
const readerActivityPeriod = ref('week')

// 日期范围
const dateRange = ref<[Date, Date] | null>(null)

// 热门图书
const hotBooks = ref([
  { title: 'Java编程思想', author: 'Bruce Eckel', borrowCount: 56 },
  { title: '设计模式', author: 'Gang of Four', borrowCount: 48 },
  { title: '算法导论', author: 'Thomas H. Cormen', borrowCount: 42 },
  { title: '重构', author: 'Martin Fowler', borrowCount: 39 },
  { title: '代码整洁之道', author: 'Robert C. Martin', borrowCount: 35 },
  { title: '深入理解计算机系统', author: 'Randal E. Bryant', borrowCount: 32 },
  { title: '数据库系统概念', author: 'Abraham Silberschatz', borrowCount: 28 },
  { title: '编译原理', author: 'Alfred V. Aho', borrowCount: 24 },
  { title: 'TCP/IP详解', author: 'W. Richard Stevens', borrowCount: 21 },
  { title: 'Linux内核设计与实现', author: 'Robert Love', borrowCount: 18 }
])

// 数据汇总
const summary = reactive({
  newBooks: 156,
  newUsers: 42,
  totalBorrowings: 892,
  overdueBooks: 17
})

// 初始化借阅统计图表
const initBorrowChart = () => {
  if (!borrowChartRef.value) return
  
  borrowChartInstance = echarts.init(borrowChartRef.value)
  
  const option = {
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['借出', '归还']
    },
    xAxis: {
      type: 'category',
      data: borrowChartPeriod.value === 'month' 
        ? ['第1周', '第2周', '第3周', '第4周']
        : borrowChartPeriod.value === 'quarter' 
        ? ['第1月', '第2月', '第3月']
        : ['第1季度', '第2季度', '第3季度', '第4季度']
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '借出',
        type: 'bar',
        data: borrowChartPeriod.value === 'month' 
          ? [120, 132, 101, 134]
          : borrowChartPeriod.value === 'quarter' 
          ? [320, 302, 301]
          : [820, 932, 901, 934],
        itemStyle: {
          color: '#409EFF'
        }
      },
      {
        name: '归还',
        type: 'bar',
        data: borrowChartPeriod.value === 'month' 
          ? [110, 122, 91, 124]
          : borrowChartPeriod.value === 'quarter' 
          ? [300, 282, 291]
          : [790, 902, 891, 924],
        itemStyle: {
          color: '#67C23A'
        }
      }
    ]
  }
  
  borrowChartInstance.setOption(option)
}

// 初始化图书分类图表
const initCategoryChart = () => {
  if (!categoryChartRef.value) return
  
  categoryChartInstance = echarts.init(categoryChartRef.value)
  
  const data = [
    { value: 335, name: '计算机科学' },
    { value: 310, name: '文学' },
    { value: 234, name: '历史' },
    { value: 135, name: '艺术' },
    { value: 154, name: '哲学' },
    { value: 120, name: '经济' },
    { value: 95, name: '其他' }
  ]
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 10,
      top: 'center',
      data: data.map(item => item.name)
    },
    series: [
      {
        name: '图书分类',
        type: 'pie',
        radius: categoryChartType.value === 'pie' ? '50%' : ['40%', '70%'],
        center: ['40%', '50%'],
        avoidLabelOverlap: false,
        label: {
          show: true,
          formatter: '{b}: {c}'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '18',
            fontWeight: 'bold'
          }
        },
        data
      }
    ]
  }
  
  categoryChartInstance.setOption(option)
}

// 初始化读者活跃度图表
const initReaderActivityChart = () => {
  if (!readerActivityChartRef.value) return
  
  readerActivityChartInstance = echarts.init(readerActivityChartRef.value)
  
  const option = {
    tooltip: {
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      data: readerActivityPeriod.value === 'week' 
        ? ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
        : Array.from({ length: 30 }, (_, i) => `${i + 1}日`)
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '活跃人数',
        type: 'line',
        smooth: true,
        data: readerActivityPeriod.value === 'week'
          ? [120, 132, 101, 134, 90, 230, 210]
          : Array.from({ length: 30 }, () => Math.floor(Math.random() * 200) + 50),
        itemStyle: {
          color: '#E6A23C'
        },
        areaStyle: {
          opacity: 0.3
        }
      }
    ]
  }
  
  readerActivityChartInstance.setOption(option)
}

// 监听窗口大小变化
const handleResize = () => {
  borrowChartInstance?.resize()
  categoryChartInstance?.resize()
  readerActivityChartInstance?.resize()
}

// 导出报表
const handleExport = () => {
  ElMessage.success('导出成功')
}

// 加载汇总数据
const loadSummary = () => {
  // 这里应该调用实际的API
  // const response = await api.get('/reports/summary', {
  //   params: {
  //     startDate: dateRange.value?.[0].toISOString().split('T')[0],
  //     endDate: dateRange.value?.[1].toISOString().split('T')[0]
  //   }
  // })
  // summary.value = response.data
  
  // 模拟数据变化
  summary.newBooks = Math.floor(Math.random() * 200) + 100
  summary.newUsers = Math.floor(Math.random() * 50) + 20
  summary.totalBorrowings = Math.floor(Math.random() * 1000) + 500
  summary.overdueBooks = Math.floor(Math.random() * 20) + 10
}

// 监听参数变化
const watchParamsChange = () => {
  nextTick(() => {
    initBorrowChart()
    initCategoryChart()
    initReaderActivityChart()
  })
}

onMounted(() => {
  nextTick(() => {
    initBorrowChart()
    initCategoryChart()
    initReaderActivityChart()
    window.addEventListener('resize', handleResize)
  })
})

// 组件卸载时移除事件监听
onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  borrowChartInstance?.dispose()
  categoryChartInstance?.dispose()
  readerActivityChartInstance?.dispose()
})
</script>

<style scoped>
.reports-container {
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

.chart-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 500;
}

.chart-container {
  height: 300px;
  width: 100%;
}

.chart {
  width: 100%;
  height: 100%;
}

.summary-card {
  background-color: #f5f7fa;
}

.summary-item {
  text-align: center;
  padding: 20px 0;
}

.summary-label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.summary-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
}
</style>