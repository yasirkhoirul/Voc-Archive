import { db } from "../config/firebase";
import {
  DisplayItem,
  CreateDisplayInput,
  UpdateDisplayInput,
} from "../models/display.model";
import { validateRequiredString } from "../utils/validators";
import { FieldValue } from "firebase-admin/firestore";

const DISPLAY_ITEMS_COLLECTION = "display_items";
const MAX_PRODUCT_IDS = 5;

export class DisplayService {
  /**
   * Validates product_ids array: must be non-empty and max 5 items.
   */
  private static validateProductIds(productIds: string[]): void {
    if (!Array.isArray(productIds) || productIds.length === 0) {
      throw new Error("product_ids must be a non-empty array.");
    }
    if (productIds.length > MAX_PRODUCT_IDS) {
      throw new Error(`product_ids cannot exceed ${MAX_PRODUCT_IDS} items. Got: ${productIds.length}`);
    }
    for (const id of productIds) {
      if (typeof id !== "string" || id.trim().length === 0) {
        throw new Error("Each product_id must be a non-empty string.");
      }
    }
  }

  /**
   * Creates a new display item (e.g. "Recommended Items").
   */
  static async createDisplay(input: CreateDisplayInput): Promise<DisplayItem> {
    validateRequiredString(input.judul, "judul");
    this.validateProductIds(input.product_ids);

    const docRef = db.collection(DISPLAY_ITEMS_COLLECTION).doc();
    const now = FieldValue.serverTimestamp();

    const displayData = {
      uid: docRef.id,
      judul: input.judul,
      product_ids: input.product_ids,
      created_at: now,
      updated_at: now,
    };

    await docRef.set(displayData);

    const doc = await docRef.get();
    return doc.data() as DisplayItem;
  }

  /**
   * Updates an existing display item.
   */
  static async updateDisplay(input: UpdateDisplayInput): Promise<DisplayItem> {
    const docRef = db.collection(DISPLAY_ITEMS_COLLECTION).doc(input.uid);
    const existingDoc = await docRef.get();

    if (!existingDoc.exists) {
      throw new Error(`Display item with uid "${input.uid}" not found.`);
    }

    if (input.judul !== undefined) validateRequiredString(input.judul, "judul");
    if (input.product_ids !== undefined) this.validateProductIds(input.product_ids);

    const updateData: Record<string, unknown> = {
      updated_at: FieldValue.serverTimestamp(),
    };

    if (input.judul !== undefined) updateData.judul = input.judul;
    if (input.product_ids !== undefined) updateData.product_ids = input.product_ids;

    await docRef.update(updateData);

    const doc = await docRef.get();
    return doc.data() as DisplayItem;
  }

  /**
   * Deletes a display item.
   */
  static async deleteDisplay(uid: string): Promise<void> {
    const docRef = db.collection(DISPLAY_ITEMS_COLLECTION).doc(uid);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Display item with uid "${uid}" not found.`);
    }

    await docRef.delete();
  }
}
