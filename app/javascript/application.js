// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "controllers"

// Handle Turbo navigation
document.addEventListener("turbo:load", () => {
  // Ensure dropdowns are closed after navigation
  document.querySelectorAll('[data-location-select-target="menu"]').forEach(menu => {
    menu.classList.add('hidden')
  })
})

// Copy to clipboard functionality
window.copyToClipboard = function(text) {
  if (!text) {
    const codeElement = document.getElementById('reset-code');
    text = codeElement ? codeElement.textContent : '';
  }
  
  if (!text) return;
  
  navigator.clipboard.writeText(text).then(() => {
    // Show success message
    const notification = document.createElement('div');
    notification.className = 'fixed bottom-4 right-4 bg-green-100 text-green-800 px-4 py-2 rounded-md shadow-md';
    notification.textContent = 'Copied to clipboard!';
    document.body.appendChild(notification);
    
    // Remove after 2 seconds
    setTimeout(() => {
      notification.remove();
    }, 2000);
  }).catch(err => {
    console.error('Failed to copy text: ', err);
  });
}

// Date picker initialization
document.addEventListener('DOMContentLoaded', function() {
  const dateInputs = document.querySelectorAll('input[type="date"]');
  
  dateInputs.forEach(input => {
    // Add placeholder support for browsers that don't show it
    input.addEventListener('focus', function() {
      if (this.value === '') {
        this.type = 'date';
      }
    });
    
    input.addEventListener('blur', function() {
      if (this.value === '') {
        this.type = 'text';
      }
    });
  });
});

// Dropdown menus
document.addEventListener('click', function(e) {
  // Close any open dropdown when clicking outside
  const dropdowns = document.querySelectorAll('.dropdown-menu');
  dropdowns.forEach(dropdown => {
    if (!dropdown.contains(e.target) && !dropdown.previousElementSibling.contains(e.target)) {
      dropdown.classList.add('hidden');
    }
  });
});

// Toggle dropdown menu
window.toggleDropdown = function(id) {
  const menu = document.getElementById(id);
  if (menu) {
    menu.classList.toggle('hidden');
  }
}