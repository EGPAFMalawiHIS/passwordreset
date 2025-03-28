// Import and register all your controllers from the controllers directory
import { application } from "./application"

// Register all controllers in the controllers directory
import DropdownController from "./dropdown_controller"
import MobileMenuController from "./mobile_menu_controller"
import FlashController from "./flash_controller"

application.register("dropdown", DropdownController)
application.register("mobile-menu", MobileMenuController)
application.register("flash", FlashController)

// You can also register controllers manually:
// import { Controller } from "@hotwired/stimulus"
//
// export default class extends Controller {
//   // ...controller code
// }

