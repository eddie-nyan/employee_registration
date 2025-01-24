import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["table", "searchInput", "perPage", "loading"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    perPage: { type: Number, default: 10 },
    sort: { type: String, default: "created_at" },
    direction: { type: String, default: "desc" }
  }

  connect() {
    this.loadData()
    this.setupSearchListeners()
  }

  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
  }

  setupSearchListeners() {
    // Auto-search with debounce
    this.searchInputTarget.addEventListener('input', (event) => {
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout)
      }
      
      this.searchTimeout = setTimeout(() => {
        this.performSearch()
      }, 300)
    })

    // Search on Enter key
    this.searchInputTarget.addEventListener('keypress', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault()
        if (this.searchTimeout) {
          clearTimeout(this.searchTimeout)
        }
        this.performSearch()
      }
    })
  }

  performSearch() {
    this.pageValue = 1
    this.loadData()
  }

  changePage(event) {
    event.preventDefault()
    const page = event.params.page
    if (page > 0) {
      this.pageValue = page
      this.loadData()
    }
  }

  changePerPage() {
    this.pageValue = 1
    this.perPageValue = parseInt(this.perPageTarget.value)
    this.loadData()
  }

  sort(event) {
    event.preventDefault()
    const column = event.currentTarget.dataset.column

    // Toggle direction if clicking the same column
    if (column === this.sortValue) {
      this.directionValue = this.directionValue === "asc" ? "desc" : "asc"
    } else {
      this.sortValue = column
      this.directionValue = "asc"
    }

    this.loadData()
  }

  loadData() {
    const searchQuery = this.searchInputTarget.value.trim()
    const url = new URL(this.urlValue, window.location.origin)
    
    url.searchParams.set('query', searchQuery)
    url.searchParams.set('page', this.pageValue)
    url.searchParams.set('per_page', this.perPageValue)
    url.searchParams.set('sort', this.sortValue)
    url.searchParams.set('direction', this.directionValue)

    this.showLoading()

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-CSRF-Token': csrfToken,
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.text()
    })
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Search error:', error)
    })
    .finally(() => {
      this.hideLoading()
    })
  }

  showLoading() {
    this.loadingTarget.classList.remove('hidden')
  }

  hideLoading() {
    this.loadingTarget.classList.add('hidden')
  }
} 