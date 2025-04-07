document.addEventListener('DOMContentLoaded', () => {
  const locationSelects = document.querySelectorAll('[data-controller="location-select"]')
  
  locationSelects.forEach(container => {
    const button = container.querySelector('button')
    const menu = container.querySelector('[data-location-select-target="menu"]')
    const searchInput = container.querySelector('[data-location-select-target="searchInput"]')
    const locationItems = container.querySelectorAll('[data-location-id]')
    
    // Toggle dropdown
    button.addEventListener('click', (event) => {
      event.stopPropagation()
      menu.classList.toggle('hidden')
    })
    
    // Close dropdown when clicking outside
    document.addEventListener('click', (event) => {
      if (!container.contains(event.target)) {
        menu.classList.add('hidden')
      }
    })
    
    // Search functionality
    if (searchInput) {
      searchInput.addEventListener('input', () => {
        const searchTerm = searchInput.value.toLowerCase()
        
        locationItems.forEach(item => {
          const text = item.textContent.toLowerCase()
          item.style.display = text.includes(searchTerm) ? 'block' : 'none'
        })
      })
    }
    
    // Select location
    locationItems.forEach(item => {
      item.addEventListener('click', () => {
        const locationId = item.getAttribute('data-location-id')
        const locationName = item.textContent.trim()
        
        // Update hidden input
        const hiddenInput = container.querySelector('input[type="hidden"]')
        if (hiddenInput) {
          hiddenInput.value = locationId
        }
        
        // Update button text
        button.querySelector('span').textContent = locationName
        
        // Close dropdown
        menu.classList.add('hidden')
      })
    })
  })
})
