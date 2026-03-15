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
export { createProduct, updateProduct, updateStock } from "./functions/product.functions";
