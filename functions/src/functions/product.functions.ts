import { onCall, HttpsError } from "firebase-functions/v2/https";
import { ProductService } from "../services/product.service";
import { UserService } from "../services/user.service";
import { CreateProductInput, UpdateProductInput, UpdateStockInput } from "../models/product.model";

/**
 * Callable function: createProduct
 * Only accessible by admin users.
 */
export const createProduct = onCall(async (request) => {
    // Authentication check
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be authenticated.");
    }

    // Admin role check
    const isAdmin = await UserService.isAdmin(request.auth.uid);
    if (!isAdmin) {
        throw new HttpsError("permission-denied", "Only admin users can create products.");
    }

    try {
        const input = request.data as CreateProductInput;
        const product = await ProductService.createProduct(input);
        return { success: true, data: product };
    } catch (error) {
        const message = error instanceof Error ? error.message : "Unknown error occurred.";
        throw new HttpsError("invalid-argument", message);
    }
});

/**
 * Callable function: updateProduct
 * Only accessible by admin users.
 * Automatically recalculates total_stok and harga_diskon.
 */
export const updateProduct = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be authenticated.");
    }

    const isAdmin = await UserService.isAdmin(request.auth.uid);
    if (!isAdmin) {
        throw new HttpsError("permission-denied", "Only admin users can update products.");
    }

    try {
        const input = request.data as UpdateProductInput;

        if (!input.uid) {
            throw new Error("Product uid is required for update.");
        }

        const product = await ProductService.updateProduct(input);
        return { success: true, data: product };
    } catch (error) {
        const message = error instanceof Error ? error.message : "Unknown error occurred.";
        throw new HttpsError("invalid-argument", message);
    }
});

/**
 * Callable function: updateStock
 * Only accessible by admin users.
 * Updates stock for specific sizes and recalculates total_stok.
 * Uses Firestore transaction for atomicity.
 */
export const updateStock = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be authenticated.");
    }

    const isAdmin = await UserService.isAdmin(request.auth.uid);
    if (!isAdmin) {
        throw new HttpsError("permission-denied", "Only admin users can update stock.");
    }

    try {
        const input = request.data as UpdateStockInput;

        if (!input.uid) {
            throw new Error("Product uid is required.");
        }

        if (!input.stock_changes || Object.keys(input.stock_changes).length === 0) {
            throw new Error("stock_changes is required and must not be empty.");
        }

        const product = await ProductService.updateStock(input);
        return { success: true, data: product };
    } catch (error) {
        const message = error instanceof Error ? error.message : "Unknown error occurred.";
        throw new HttpsError("invalid-argument", message);
    }
});
