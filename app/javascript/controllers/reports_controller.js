import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tab", "content" ]

  connect() {
    // Ensure tabs are properly initialized
    this.setupTabs()
  }

  setupTabs() {
    const tabs = this.tabTargets
    const contents = this.contentTargets

    tabs.forEach((tab, index) => {
      tab.addEventListener('click', (event) => {
        // Remove active class from all tabs and contents
        tabs.forEach(t => t.classList.remove('active'))
        contents.forEach(c => c.classList.remove('active'))

        // Add active class to clicked tab and corresponding content
        event.currentTarget.classList.add('active')
        if (contents[index]) {
          contents[index].classList.add('active')
        }
      })
    })
  }

  filterTab(event) {
    const tabValue = event.currentTarget.getAttribute('data-tab-value')
    
    // Safely handle tab filtering
    const tabs = document.querySelectorAll('[data-tab-value]')
    const contents = document.querySelectorAll('[data-tab-content]')

    tabs.forEach(tab => {
      tab.classList.remove('active')
      if (tab.getAttribute('data-tab-value') === tabValue) {
        tab.classList.add('active')
      }
    })

    contents.forEach(content => {
      content.classList.remove('active')
      if (content.getAttribute('data-tab-content') === tabValue) {
        content.classList.add('active')
      }
    })
  }
}
