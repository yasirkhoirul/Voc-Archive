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
  getDisplaySections,
} from "./functions/display.functions";

// Settings Functions
export {
  setExchangeRate,
  addShippingRate,
  updateShippingRate,
  deleteShippingRate,
} from "./functions/settings.functions";

// Brand Functions
export {
  createBrand,
  updateBrand,
  deleteBrand,
} from "./functions/brand.functions";

// Payment Functions
export {
  createXenditInvoice,
  createPaypalManualTransaction,
  checkXenditStatus,
  xenditWebhook,
  syncPendingXenditOrders,
  syncUserPendingXenditOrders,
  confirmPaypalOrder,
  rejectPaypalOrder,
} from "./functions/payment.functions";

// About Us Functions
export {
  getAboutUsContent,
  updateAboutUsContent,
} from "./functions/aboutus.functions";
