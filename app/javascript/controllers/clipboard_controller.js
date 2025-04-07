import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["source", "button"]
  static values = {
    successMessage: { type: String, default: "Copied!" },
    originalMessage: { type: String, default: "Copy" }
  }
  
  copy() {
    navigator.clipboard.writeText(this.sourceTarget.textContent.trim())
      .then(() => {
        const originalText = this.buttonTarget.textContent
        this.buttonTarget.textContent = this.successMessageValue
        
        setTimeout(() => {
          this.buttonTarget.textContent = this.originalMessageValue
        }, 2000)
      })
      .catch(err => {
        console.error('Failed to copy text: ', err)
      })
  }
}