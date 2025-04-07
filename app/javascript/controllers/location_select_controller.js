import { Controller } from "@hotwired/stimulus"

export class LocationSelectController extends Controller {
  static targets = [ "button", "menu", "searchInput" ]

  connect() {
    this.isOpen = false
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Toggle dropdown on button click
    this.buttonTarget.addEventListener('click', (event) => {
      event.stopPropagation()
      this.toggleDropdown()
    })

    // Search functionality
    this.searchInputTarget.addEventListener('input', () => {
      this.filterLocations()
    })

    // Close dropdown when clicking outside
    document.addEventListener('click', (event) => {
      if (!this.element.contains(event.target) && this.isOpen) {
        this.closeDropdown()
      }
    })
  }

  toggleDropdown() {
    this.isOpen = !this.isOpen
    this.menuTarget.classList.toggle('hidden', !this.isOpen)
  }

  closeDropdown() {
    this.isOpen = false
    this.menuTarget.classList.add('hidden')
  }

  filterLocations() {
    const searchTerm = this.searchInputTarget.value.toLowerCase()
    const items = this.menuTarget.querySelectorAll('a')

    items.forEach((item) => {
      const text = item.textContent.toLowerCase()
      if (text.includes(searchTerm)) {
        item.style.display = 'block'
      } else {
        item.style.display = 'none'
      }
    })
  }

  selectLocation(event) {
    event.preventDefault()
    const selectedLocationId = event.currentTarget.dataset.locationId
    const selectedLocationName = event.currentTarget.textContent.trim()

    // Update hidden input with selected location ID
    const hiddenInput = this.element.querySelector('input[type="hidden"]')
    if (hiddenInput) {
      hiddenInput.value = selectedLocationId
    }

    // Update button text
    this.buttonTarget.querySelector('span').textContent = selectedLocationName

    // Close dropdown
    this.closeDropdown()
  }
}

export default LocationSelectController
