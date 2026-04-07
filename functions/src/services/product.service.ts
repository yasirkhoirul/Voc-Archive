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
  validateBase64Images,
} from "../utils/validators";
import { StorageService } from "./storage.service";
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
   * Uploads images to Storage and saves download URLs.
   */
  static async createProduct(input: CreateProductInput): Promise<Product> {
    // Validate input
    validateBase64Images(input.gambar_base64);
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

    const docRef = db.collection(PRODUCTS_COLLECTION).doc();
    const productUid = docRef.id;

    // Upload images to Storage
    const uploadResults = await StorageService.uploadImages(
      input.gambar_base64,
      `products/${productUid}`,
    );

    const gambarUrls = uploadResults.map((r) => r.url);
    const gambarPaths = uploadResults.map((r) => r.path);

    const now = FieldValue.serverTimestamp();
    const productData = {
      uid: productUid,
      gambar: gambarUrls,
      gambar_paths: gambarPaths,
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
   * If new images are provided, old images are deleted from Storage.
   */
  static async updateProduct(input: UpdateProductInput): Promise<Product> {
    const docRef = db.collection(PRODUCTS_COLLECTION).doc(input.uid);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      throw new Error(`Product with uid "${input.uid}" not found.`);
    }

    const existingData = existingDoc.data() as Product;

    // Validate provided fields
    if (input.gambar_base64 !== undefined) validateBase64Images(input.gambar_base64);
    if (input.nama_brand !== undefined) validateRequiredString(input.nama_brand, "nama_brand");
    if (input.harga !== undefined) validateNonNegativeNumber(input.harga, "harga");
    if (input.deskripsi !== undefined) validateRequiredString(input.deskripsi, "deskripsi");
    if (input.detail !== undefined) validateRequiredString(input.detail, "detail");
    if (input.sizes !== undefined) validateSizes(input.sizes);
    if (input.diskon !== undefined) validateDiscount(input.diskon);

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

    // Handle image update: delete unkept old images, upload new ones
    if (input.gambar_base64 !== undefined || input.keep_gambar_paths !== undefined) {
      let finalGambarPaths: string[] = [];
      let finalGambarUrls: string[] = [];

      const pathsToKeep = input.keep_gambar_paths || [];
      const currentPaths = existingData.gambar_paths || [];
      const currentUrls = existingData.gambar || [];
      
      const pathsToDelete = currentPaths.filter((p) => !pathsToKeep.includes(p));

      // Delete old images that are not kept
      if (pathsToDelete.length > 0) {
        await StorageService.deleteImages(pathsToDelete);
      }

      // Add kept images to final list
      pathsToKeep.forEach((p) => {
        const idx = currentPaths.indexOf(p);
        if (idx !== -1) {
          finalGambarPaths.push(p);
          finalGambarUrls.push(currentUrls[idx]);
        }
      });

      // Upload new images
      if (input.gambar_base64 && input.gambar_base64.length > 0) {
        const uploadResults = await StorageService.uploadImages(
          input.gambar_base64,
          `products/${input.uid}`,
        );
        finalGambarUrls = finalGambarUrls.concat(uploadResults.map((r) => r.url));
        finalGambarPaths = finalGambarPaths.concat(uploadResults.map((r) => r.path));
      }

      updateData.gambar = finalGambarUrls;
      updateData.gambar_paths = finalGambarPaths;
    }

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
   * Deletes a product and all its images from Storage.
   */
  static async deleteProduct(uid: string): Promise<void> {
    const docRef = db.collection(PRODUCTS_COLLECTION).doc(uid);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Product with uid "${uid}" not found.`);
    }

    const data = doc.data() as Product;

    // Delete images from Storage
    if (data.gambar_paths && data.gambar_paths.length > 0) {
      await StorageService.deleteImages(data.gambar_paths);
    }

    // Delete the document
    await docRef.delete();
  }

  /**
   * Updates stock for specific sizes (atomic transaction).
   */
  static async updateStock(input: UpdateStockInput): Promise<Product> {
    const docRef = db.collection(PRODUCTS_COLLECTION).doc(input.uid);

    const result = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);

      if (!doc.exists) {
        throw new Error(`Product with uid "${input.uid}" not found.`);
      }

      const existingData = doc.data() as Product;
      const updatedSizes = { ...existingData.sizes };

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
