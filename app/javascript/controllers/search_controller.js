import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "results"]
  
  connect() {
    this.timeout = null
  }
  
  search() {
    clearTimeout(this.timeout)
    console.log(this.inputTarget.value,"....")
    
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}