import { defineStore } from 'pinia'
import { ref } from 'vue'
import { bookApi } from '@/api/book'
import { type Book, type BookQuery } from '@/types/book'
import { ElMessage } from 'element-plus'

export const useBookStore = defineStore('book', () => {
  const books = ref<Book[]>([])
  const book = ref<Book | null>(null)
  const total = ref(0)
  const loading = ref(false)

  // 获取图书列表
  const getBooks = async (query?: BookQuery) => {
    loading.value = true
    try {
      const response = await bookApi.getBooks(query)
      books.value = response.data.content || response.data
      total.value = response.data.totalElements || books.value.length
      return response.data
    } catch (error: any) {
      console.error('获取图书列表失败:', error)
      ElMessage.error('获取图书列表失败，请重试')
      throw error
    } finally {
      loading.value = false
    }
  }

  // 获取图书详情
  const getBookById = async (id: number) => {
    loading.value = true
    try {
      const response = await bookApi.getBookById(id)
      book.value = response.data
      return response.data
    } catch (error: any) {
      console.error('获取图书详情失败:', error)
      ElMessage.error('获取图书详情失败，请重试')
      throw error
    } finally {
      loading.value = false
    }
  }

  // 创建图书
  const createBook = async (bookData: Omit<Book, 'id'>) => {
    loading.value = true
    try {
      const response = await bookApi.createBook(bookData)
      books.value.unshift(response.data)
      ElMessage.success('图书创建成功')
      return response.data
    } catch (error: any) {
      console.error('创建图书失败:', error)
      ElMessage.error(error.response?.data?.message || '创建图书失败，请重试')
      throw error
    } finally {
      loading.value = false
    }
  }

  // 更新图书
  const updateBook = async (id: number, bookData: Partial<Book>) => {
    loading.value = true
    try {
      const response = await bookApi.updateBook(id, bookData)
      
      // 更新列表中的图书
      const index = books.value.findIndex(book => book.id === id)
      if (index !== -1) {
        books.value[index] = { ...books.value[index], ...response.data }
      }
      
      ElMessage.success('图书更新成功')
      return response.data
    } catch (error: any) {
      console.error('更新图书失败:', error)
      ElMessage.error(error.response?.data?.message || '更新图书失败，请重试')
      throw error
    } finally {
      loading.value = false
    }
  }

  // 删除图书
  const deleteBook = async (id: number) => {
    loading.value = true
    try {
      await bookApi.deleteBook(id)
      
      // 从列表中移除
      const index = books.value.findIndex(book => book.id === id)
      if (index !== -1) {
        books.value.splice(index, 1)
      }
      
      ElMessage.success('图书删除成功')
    } catch (error: any) {
      console.error('删除图书失败:', error)
      ElMessage.error(error.response?.data?.message || '删除图书失败，请重试')
      throw error
    } finally {
      loading.value = false
    }
  }

  // 搜索图书
  const searchBooks = async (query: BookQuery) => {
    loading.value = true
    try {
      const response = await bookApi.searchBooks(query)
      books.value = response.data.content || response.data
      total.value = response.data.totalElements || books.value.length
      return response.data
    } catch (error: any) {
      console.error('搜索图书失败:', error)
      ElMessage.error('搜索图书失败，请重试')
      throw error
    } finally {
      loading.value = false
    }
  }

  // 重置状态
  const resetBook = () => {
    book.value = null
  }

  return {
    books,
    book,
    total,
    loading,
    getBooks,
    getBookById,
    createBook,
    updateBook,
    deleteBook,
    searchBooks,
    resetBook
  }
})