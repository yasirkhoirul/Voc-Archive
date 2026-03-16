/**
 * VOC Archive - Firebase Cloud Functions
 *
 * Entry point for all cloud functions.
 */

// Initialize Firebase Admin SDK (must be first)
import "./config/firebase";

// Auth Functions
export { onUserCreated } from "./functions/auth.functions";

// Product Functions
export {
  createProduct,
  updateProduct,
  deleteProduct,
  updateStock,
} from "./functions/product.functions";

// Slider Functions
export { createSlider, deleteSlider } from "./functions/slider.functions";

// Display Item Functions
export {
  createDisplay,
  updateDisplay,
  deleteDisplay,
} from "./functions/display.functions";
