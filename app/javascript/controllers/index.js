import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Manual registration of location select controller to ensure it's available
import LocationSelectController from "./location_select_controller"
application.register("location-select", LocationSelectController)
