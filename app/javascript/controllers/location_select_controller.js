import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    // Add click outside listener when controller connects
    document.addEventListener('click', this.closeOnClickOutside.bind(this))
  }

  disconnect() {
    // Remove click outside listener when controller disconnects
    document.removeEventListener('click', this.closeOnClickOutside.bind(this))
  }

  closeOnClickOutside(event) {
    // Close menu if click is outside the controller element
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden')
    }
  }

  toggleMenu(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    this.menuTarget.classList.toggle('hidden')
  }

  selectLocation(event) {
    event.preventDefault()
    
    const locationId = event.currentTarget.dataset.locationId
    const locationName = event.currentTarget.textContent.trim()
    
    const locationInput = document.getElementById('location_id')
    if (locationInput) {
      locationInput.value = locationId
      this.buttonTarget.querySelector('span').textContent = locationName
      this.menuTarget.classList.add('hidden')
    }
  }
}
