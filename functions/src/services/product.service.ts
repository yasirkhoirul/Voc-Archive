import { db } from "../config/firebase";
import {
    Product,
    CreateProductInput,
    UpdateProductInput,
    UpdateStockInput,
    SizeKey,
} from "../models/product.model";
import {
    validateSizes,
    validateRequiredString,
    validateNonNegativeNumber,
    validateDiscount,
    validateGambar,
} from "../utils/validators";
import { FieldValue } from "firebase-admin/firestore";

const PRODUCTS_COLLECTION = "products";
const VALID_SIZES: SizeKey[] = ["onesize", "xs", "s", "m", "l", "xl", "xxl"];

export class ProductService {
    /**
     * Calculates total stock by summing all size stocks.
     */
    static calculateTotalStock(sizes: Record<string, number>): number {
        return Object.values(sizes).reduce((sum, qty) => sum + qty, 0);
    }

    /**
     * Calculates discounted price.
     * @param harga - Original price
     * @param diskon - Discount percentage (0-100)
     * @returns Discounted price (rounded to nearest integer)
     */
    static calculateDiscountPrice(harga: number, diskon: number): number {
        if (diskon <= 0) return harga;
        return Math.round(harga * (1 - diskon / 100));
    }

    /**
     * Normalizes sizes map to include all valid sizes with 0 as default.
     */
    static normalizeSizes(sizes: Record<string, number>): Record<SizeKey, number> {
        const normalized: Record<string, number> = {};
        for (const size of VALID_SIZES) {
            normalized[size] = sizes[size] ?? 0;
        }
        return normalized as Record<SizeKey, number>;
    }

    /**
     * Creates a new product document in Firestore.
     */
    static async createProduct(input: CreateProductInput): Promise<Product> {
        // Validate input
        validateGambar(input.gambar);
        validateRequiredString(input.nama_brand, "nama_brand");
        validateNonNegativeNumber(input.harga, "harga");
        validateRequiredString(input.deskripsi, "deskripsi");
        validateRequiredString(input.detail, "detail");
        validateSizes(input.sizes);
        validateDiscount(input.diskon);

        const diskon = input.diskon ?? 0;
        const sizes = this.normalizeSizes(input.sizes);
        const totalStok = this.calculateTotalStock(sizes);
        const hargaDiskon = this.calculateDiscountPrice(input.harga, diskon);

        const now = FieldValue.serverTimestamp();
        const docRef = db.collection(PRODUCTS_COLLECTION).doc();

        const productData = {
            uid: docRef.id,
            gambar: input.gambar,
            nama_brand: input.nama_brand,
            harga: input.harga,
            deskripsi: input.deskripsi,
            detail: input.detail,
            sizes,
            total_stok: totalStok,
            diskon,
            harga_diskon: hargaDiskon,
            created_at: now,
            updated_at: now,
        };

        await docRef.set(productData);

        const doc = await docRef.get();
        return doc.data() as Product;
    }

    /**
     * Updates an existing product document.
     * Automatically recalculates total_stok and harga_diskon when relevant fields change.
     */
    static async updateProduct(input: UpdateProductInput): Promise<Product> {
        const docRef = db.collection(PRODUCTS_COLLECTION).doc(input.uid);
        const existingDoc = await docRef.get();

        if (!existingDoc.exists) {
            throw new Error(`Product with uid "${input.uid}" not found.`);
        }

        const existingData = existingDoc.data() as Product;

        // Validate provided fields
        if (input.gambar !== undefined) validateGambar(input.gambar);
        if (input.nama_brand !== undefined) validateRequiredString(input.nama_brand, "nama_brand");
        if (input.harga !== undefined) validateNonNegativeNumber(input.harga, "harga");
        if (input.deskripsi !== undefined) validateRequiredString(input.deskripsi, "deskripsi");
        if (input.detail !== undefined) validateRequiredString(input.detail, "detail");
        if (input.sizes !== undefined) validateSizes(input.sizes);
        if (input.diskon !== undefined) validateDiscount(input.diskon);

        // Merge with existing data
        const updatedSizes = input.sizes
            ? this.normalizeSizes(input.sizes)
            : existingData.sizes;

        const updatedHarga = input.harga ?? existingData.harga;
        const updatedDiskon = input.diskon ?? existingData.diskon;

        const totalStok = this.calculateTotalStock(updatedSizes);
        const hargaDiskon = this.calculateDiscountPrice(updatedHarga, updatedDiskon);

        const updateData: Record<string, unknown> = {
            updated_at: FieldValue.serverTimestamp(),
            total_stok: totalStok,
            harga_diskon: hargaDiskon,
        };

        // Only include changed fields
        if (input.gambar !== undefined) updateData.gambar = input.gambar;
        if (input.nama_brand !== undefined) updateData.nama_brand = input.nama_brand;
        if (input.harga !== undefined) updateData.harga = input.harga;
        if (input.deskripsi !== undefined) updateData.deskripsi = input.deskripsi;
        if (input.detail !== undefined) updateData.detail = input.detail;
        if (input.sizes !== undefined) updateData.sizes = updatedSizes;
        if (input.diskon !== undefined) updateData.diskon = input.diskon;

        await docRef.update(updateData);

        const doc = await docRef.get();
        return doc.data() as Product;
    }

    /**
     * Updates stock for specific sizes.
     * stock_changes values can be positive (add stock) or negative (reduce stock).
     * Stock per size cannot go below 0.
     */
    static async updateStock(input: UpdateStockInput): Promise<Product> {
        const docRef = db.collection(PRODUCTS_COLLECTION).doc(input.uid);

        // Use transaction for atomic stock update
        const result = await db.runTransaction(async (transaction) => {
            const doc = await transaction.get(docRef);

            if (!doc.exists) {
                throw new Error(`Product with uid "${input.uid}" not found.`);
            }

            const existingData = doc.data() as Product;
            const updatedSizes = { ...existingData.sizes };

            // Apply stock changes
            for (const [sizeKey, change] of Object.entries(input.stock_changes)) {
                if (!VALID_SIZES.includes(sizeKey as SizeKey)) {
                    throw new Error(`Invalid size key: "${sizeKey}".`);
                }

                const currentStock = updatedSizes[sizeKey as SizeKey] ?? 0;
                const newStock = currentStock + change;

                if (newStock < 0) {
                    throw new Error(
                        `Stock for size "${sizeKey}" cannot go below 0. ` +
                        `Current: ${currentStock}, Change: ${change}.`
                    );
                }

                updatedSizes[sizeKey as SizeKey] = newStock;
            }

            const totalStok = ProductService.calculateTotalStock(updatedSizes);

            transaction.update(docRef, {
                sizes: updatedSizes,
                total_stok: totalStok,
                updated_at: FieldValue.serverTimestamp(),
            });

            return {
                ...existingData,
                sizes: updatedSizes,
                total_stok: totalStok,
            } as Product;
        });

        return result;
    }
}
