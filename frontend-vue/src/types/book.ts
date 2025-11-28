export interface Book {
  id: number
  isbn: string
  title: string
  author: string
  publisher: string
  publishYear: number
  price: number
  category?: string
  language?: string
  location?: string
  coverImageUrl?: string
  description?: string
  totalQuantity?: number
  availableQuantity?: number
  status?: 'AVAILABLE' | 'UNAVAILABLE' | 'MAINTENANCE'
  createdAt?: string
  updatedAt?: string
}

export interface BookQuery {
  page?: number
  size?: number
  sortBy?: string
  sortDir?: 'asc' | 'desc'
  title?: string
  author?: string
  publisher?: string
  isbn?: string
  category?: string
  language?: string
}

export interface BookForm {
  isbn: string
  title: string
  author: string
  publisher: string
  publishYear: number
  price: number
  category?: string
  language?: string
  location?: string
  description?: string
}

export interface BookResponse {
  content: Book[]
  totalElements: number
  totalPages: number
  size: number
  number: number
  first: boolean
  last: boolean
}