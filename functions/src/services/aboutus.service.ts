import { db } from "../config/firebase";
import { StorageService } from "./storage.service";
import { FieldValue } from "firebase-admin/firestore";

const SETTINGS_COLLECTION = "settings";
const ABOUT_US_DOC = "about_us";

export interface AboutUsData {
  hero_image?: string;
  hero_image_path?: string;
  title?: string;
  subtitle?: string;
  location?: string;
  body_title?: string;
  body_text?: string;
  gallery_images?: string[];
  gallery_image_paths?: string[];
  updated_at?: FirebaseFirestore.Timestamp;
}

export interface UpdateAboutUsInput {
  hero_image_base64?: string;
  title?: string;
  subtitle?: string;
  location?: string;
  body_title?: string;
  body_text?: string;
  gallery_images_base64?: string[];
  keep_gallery_images?: string[];
}

export class AboutUsService {
  /**
   * Get the about us content from Firestore.
   */
  static async getAboutUs(): Promise<AboutUsData> {
    const doc = await db.collection(SETTINGS_COLLECTION).doc(ABOUT_US_DOC).get();
    if (!doc.exists) {
      return {};
    }
    return doc.data() as AboutUsData;
  }

  /**
   * Update the about us content.
   * Handles image uploads for hero_image and gallery_images.
   */
  static async updateAboutUs(input: UpdateAboutUsInput): Promise<AboutUsData> {
    const docRef = db.collection(SETTINGS_COLLECTION).doc(ABOUT_US_DOC);
    const existingDoc = await docRef.get();
    const existingData = existingDoc.exists ? (existingDoc.data() as AboutUsData) : {};

    const updateData: Record<string, unknown> = {
      updated_at: FieldValue.serverTimestamp(),
    };

    // Handle text fields
    if (input.title !== undefined) updateData.title = input.title;
    if (input.subtitle !== undefined) updateData.subtitle = input.subtitle;
    if (input.location !== undefined) updateData.location = input.location;
    if (input.body_title !== undefined) updateData.body_title = input.body_title;
    if (input.body_text !== undefined) updateData.body_text = input.body_text;

    // Handle hero image upload
    if (input.hero_image_base64) {
      // Delete old hero image if exists
      if (existingData.hero_image_path) {
        await StorageService.deleteImage(existingData.hero_image_path);
      }

      const storagePath = `about_us/hero_${Date.now()}.jpg`;
      const url = await StorageService.uploadImage(input.hero_image_base64, storagePath);
      updateData.hero_image = url;
      updateData.hero_image_path = storagePath;
    }

    // Handle gallery images
    if (input.gallery_images_base64 || input.keep_gallery_images) {
      const keepUrls = input.keep_gallery_images || [];
      const keepPaths: string[] = [];

      // Determine which old images to delete
      const oldGalleryImages = existingData.gallery_images || [];
      const oldGalleryPaths = existingData.gallery_image_paths || [];

      for (let i = 0; i < oldGalleryImages.length; i++) {
        if (keepUrls.includes(oldGalleryImages[i])) {
          keepPaths.push(oldGalleryPaths[i] || "");
        } else if (oldGalleryPaths[i]) {
          await StorageService.deleteImage(oldGalleryPaths[i]);
        }
      }

      // Upload new gallery images
      const newUrls: string[] = [...keepUrls];
      const newPaths: string[] = [...keepPaths];

      if (input.gallery_images_base64 && input.gallery_images_base64.length > 0) {
        const results = await StorageService.uploadImages(
          input.gallery_images_base64,
          "about_us/gallery"
        );
        for (const r of results) {
          newUrls.push(r.url);
          newPaths.push(r.path);
        }
      }

      updateData.gallery_images = newUrls;
      updateData.gallery_image_paths = newPaths;
    }

    await docRef.set(updateData, { merge: true });

    const updatedDoc = await docRef.get();
    return updatedDoc.data() as AboutUsData;
  }
}
