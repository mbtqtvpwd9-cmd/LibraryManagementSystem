import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { 
      title: '登录',
      requiresAuth: false
    }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/Dashboard.vue'),
    meta: { 
      title: '仪表盘',
      requiresAuth: true
    }
  },
  {
    path: '/books',
    name: 'Books',
    component: () => import('@/views/Books.vue'),
    meta: { 
      title: '图书管理',
      requiresAuth: true
    }
  },
  {
    path: '/borrowings',
    name: 'Borrowings',
    component: () => import('@/views/Borrowings.vue'),
    meta: { 
      title: '借阅管理',
      requiresAuth: true
    }
  },
  {
    path: '/users',
    name: 'Users',
    component: () => import('@/views/Users.vue'),
    meta: { 
      title: '用户管理',
      requiresAuth: true,
      requiresAdmin: true
    }
  },
  {
    path: '/reports',
    name: 'Reports',
    component: () => import('@/views/Reports.vue'),
    meta: { 
      title: '统计报表',
      requiresAuth: true
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
  // 设置页面标题
  if (to.meta.title) {
    document.title = `${to.meta.title} - 智慧图书管理系统`
  }

  // 检查认证状态
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    // 需要认证但未登录，跳转到登录页
    next({ path: '/login', query: { redirect: to.fullPath } })
  } else if (to.meta.requiresAdmin && !authStore.isAdmin) {
    // 需要管理员权限但不是管理员
    next({ path: '/dashboard' })
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    // 已登录用户访问登录页，跳转到仪表盘
    next({ path: '/dashboard' })
  } else {
    next()
  }
})

export default router