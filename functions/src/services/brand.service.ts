import { db } from "../config/firebase";
import { Brand } from "../models/brand.model";
import { validateRequiredString } from "../utils/validators";
import { FieldValue } from "firebase-admin/firestore";

const BRANDS_COLLECTION = "brands";

export class BrandService {
  /**
   * Creates a new brand.
   */
  static async createBrand(nama: string): Promise<Brand> {
    validateRequiredString(nama, "nama");

    // Check for duplicate
    const existing = await db.collection(BRANDS_COLLECTION)
      .where("nama", "==", nama)
      .get();

    if (!existing.empty) {
      throw new Error(`Brand "${nama}" sudah ada.`);
    }

    const docRef = db.collection(BRANDS_COLLECTION).doc();

    const brandData = {
      uid: docRef.id,
      nama,
      created_at: FieldValue.serverTimestamp(),
    };

    await docRef.set(brandData);

    const doc = await docRef.get();
    return doc.data() as Brand;
  }

  /**
   * Updates a brand name.
   */
  static async updateBrand(uid: string, nama: string): Promise<Brand> {
    validateRequiredString(uid, "uid");
    validateRequiredString(nama, "nama");

    const docRef = db.collection(BRANDS_COLLECTION).doc(uid);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Brand with uid "${uid}" not found.`);
    }

    await docRef.update({
      nama,
    });

    const updated = await docRef.get();
    return updated.data() as Brand;
  }

  /**
   * Deletes a brand.
   */
  static async deleteBrand(uid: string): Promise<void> {
    validateRequiredString(uid, "uid");

    const docRef = db.collection(BRANDS_COLLECTION).doc(uid);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Brand with uid "${uid}" not found.`);
    }

    await docRef.delete();
  }
}
