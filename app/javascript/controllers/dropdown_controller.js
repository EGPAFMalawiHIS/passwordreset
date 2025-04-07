import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    console.log("Dropdown controller connected");
    console.log("Dropdown element:", this.element);
    console.log("Menu target:", this.menuTarget);
    
    // Ensure the toggle action is correctly bound
    const toggleButton = this.element.querySelector('button');
    if (toggleButton) {
      console.log("Toggle button found:", toggleButton);
      toggleButton.addEventListener('click', this.toggle.bind(this));
    } else {
      console.error("No toggle button found in dropdown controller");
    }
    
    // Add global click listener to close dropdowns when clicking outside
    document.addEventListener('click', this.handleOutsideClick.bind(this));
  }

  disconnect() {
    console.log("Dropdown controller disconnected");
    // Remove the global click listener to prevent memory leaks
    document.removeEventListener('click', this.handleOutsideClick.bind(this));
  }
  
  toggle(event) {
    try {
      console.log("Toggle method called");
      // Prevent the event from propagating to the document
      if (event) {
        event.stopPropagation(); // Prevent event from bubbling
      }
      
      // Verify menu target exists
      if (!this.menuTarget) {
        console.error("No menu target found");
        return;
      }
      
      // Toggle the dropdown visibility with additional logging
      console.log("Current hidden status:", this.menuTarget.classList.contains('hidden'));
      this.menuTarget.classList.toggle('hidden');
      console.log("New hidden status:", this.menuTarget.classList.contains('hidden'));
    } catch (error) {
      console.error("Error in dropdown toggle:", error);
    }
  }

  handleOutsideClick(event) {
    // If the click is outside the dropdown, close it
    if (this.element && !this.element.contains(event.target)) {
      console.log("Clicked outside dropdown, closing");
      this.menuTarget.classList.add('hidden');
    }
  }
}