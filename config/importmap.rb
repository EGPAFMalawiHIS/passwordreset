# Pin npm packages by running rails importmap:pin
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "app/javascript/controllers/dropdown_controller", to: "controllers/dropdown_controller.js"
pin "app/javascript/controllers/location_select_controller", to: "controllers/location_select_controller.js"
pin "app/javascript/controllers/header_menu_controller", to: "controllers/header_menu_controller.js"

# Add reports controller
pin "controllers/reports_controller", to: "controllers/reports_controller.js"

# Add dropdown script
pin "dropdown", to: "dropdown.js"

# Add location select script
pin "location_select", to: "location_select.js"