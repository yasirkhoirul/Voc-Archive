import { storage } from "../config/firebase";
import { v4 as uuidv4 } from "uuid";

const bucket = storage.bucket();

/**
 * Shared Storage service for uploading and deleting files.
 */
export class StorageService {
  /**
   * Uploads a base64-encoded image to Firebase Storage.
   * @param base64Data - base64 string (with or without data URI prefix)
   * @param storagePath - destination path in Storage (e.g. "products/abc123/0.jpg")
   * @returns Public download URL
   */
  static async uploadImage(base64Data: string, storagePath: string): Promise<string> {
    // Strip data URI prefix if present (e.g. "data:image/jpeg;base64,")
    const base64Clean = base64Data.includes(",")
      ? base64Data.split(",")[1]
      : base64Data;

    const buffer = Buffer.from(base64Clean, "base64");

    // Detect content type from data URI or default to jpeg
    let contentType = "image/jpeg";
    const dataUriMatch = base64Data.match(/^data:(image\/\w+);base64,/);
    if (dataUriMatch) {
      contentType = dataUriMatch[1];
    }

    const file = bucket.file(storagePath);
    const token = uuidv4();

    await file.save(buffer, {
      metadata: {
        contentType,
        metadata: {
          firebaseStorageDownloadTokens: token,
        },
      },
    });

    // Construct the download URL
    const bucketName = bucket.name;
    const encodedPath = encodeURIComponent(storagePath);
    const downloadUrl =
      `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodedPath}?alt=media&token=${token}`;

    return downloadUrl;
  }

  /**
   * Uploads multiple base64-encoded images.
   * @returns Array of { url, path } for each uploaded image
   */
  static async uploadImages(
    base64Images: string[],
    baseStoragePath: string,
  ): Promise<{ url: string; path: string }[]> {
    const results: { url: string; path: string }[] = [];

    for (let i = 0; i < base64Images.length; i++) {
      const ext = StorageService.getExtensionFromBase64(base64Images[i]);
      const filePath = `${baseStoragePath}/${i}_${Date.now()}.${ext}`;
      const url = await StorageService.uploadImage(base64Images[i], filePath);
      results.push({ url, path: filePath });
    }

    return results;
  }

  /**
   * Deletes a single file from Storage.
   */
  static async deleteImage(storagePath: string): Promise<void> {
    try {
      await bucket.file(storagePath).delete();
    } catch (error) {
      // File might not exist, log but don't throw
      console.warn(`Failed to delete file at ${storagePath}:`, error);
    }
  }

  /**
   * Deletes multiple files from Storage.
   */
  static async deleteImages(storagePaths: string[]): Promise<void> {
    const deletePromises = storagePaths.map((p) => StorageService.deleteImage(p));
    await Promise.all(deletePromises);
  }

  /**
   * Extracts file extension from base64 data URI.
   */
  private static getExtensionFromBase64(base64Data: string): string {
    const match = base64Data.match(/^data:image\/(\w+);base64,/);
    if (match) {
      const ext = match[1];
      return ext === "jpeg" ? "jpg" : ext;
    }
    return "jpg";
  }
}
