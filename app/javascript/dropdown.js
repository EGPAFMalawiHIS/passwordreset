document.addEventListener('DOMContentLoaded', () => {
  const dropdownContainers = document.querySelectorAll('[data-controller="dropdown"]')
  
  dropdownContainers.forEach(container => {
    const toggleButton = container.querySelector('button')
    const dropdownMenu = container.querySelector('[data-dropdown-target="menu"]')
    
    if (toggleButton && dropdownMenu) {
      toggleButton.addEventListener('click', (event) => {
        event.stopPropagation()
        dropdownMenu.classList.toggle('hidden')
      })
      
      // Close dropdown when clicking outside
      document.addEventListener('click', (event) => {
        if (!container.contains(event.target)) {
          dropdownMenu.classList.add('hidden')
        }
      })
    }
  })
})
