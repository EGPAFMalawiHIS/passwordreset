import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["phone", "fullPhone", "error"]

  connect() {
    // Only initialize if not already initialized
    if (!this.element.classList.contains('phone-initialized')) {
      this.initializePhoneInput()
    }
  }

  disconnect() {
    if (this.iti) {
      this.iti.destroy()
      this.element.classList.remove('phone-initialized')
    }
  }

  initializePhoneInput() {
    const input = this.phoneTarget
    this.iti = window.intlTelInput(input, {
      utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.19/js/utils.js",
      initialCountry: "mw",
      preferredCountries: ["mw", "za", "zm", "zw", "tz"],
      separateDialCode: true,
      autoPlaceholder: "polite"
    })

    input.addEventListener('input', () => this.updateFullPhone())
    input.addEventListener('countrychange', () => this.updateFullPhone())
    
    this.element.classList.add('phone-initialized')
    
    // Initialize with any existing value
    if (input.value) {
      this.updateFullPhone()
    }
  }

  updateFullPhone() {
    const input = this.phoneTarget
    if (input.value) {
      this.fullPhoneTarget.value = this.iti.getNumber()
      this.checkPhoneExists()
    } else {
      this.errorTarget.textContent = "Please enter a valid number, phone can not be empty!!"
      this.errorTarget.style.display = 'block'
    }
  }

  checkPhoneExists() {
    fetch(`/check_phone?phone=${this.fullPhoneTarget.value}`)
      .then(response => response.json())
      .then(data => {
        if (data.error) {
          this.errorTarget.textContent = data.error
          this.errorTarget.style.display = 'block'
        } else {
          this.errorTarget.style.display = 'none'
        }

        // Handle existing user display
        let existingUserDisplay = this.element.querySelector('.existing-user-display')
        if (existingUserDisplay) {
          existingUserDisplay.remove()
        }

        if (data.username) {
          existingUserDisplay = document.createElement('div')
          existingUserDisplay.className = 'existing-user-display absolute inset-y-0 right-0 pr-3 flex items-center text-sm text-green-800'
          existingUserDisplay.textContent = `Linked to: ${data.username}`
          this.phoneTarget.parentElement.appendChild(existingUserDisplay)
        }
      })
  }
}