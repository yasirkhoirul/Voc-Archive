import { db } from "../config/firebase";
import { Slider, CreateSliderInput } from "../models/slider.model";
import { StorageService } from "./storage.service";
import { validateRequiredString, validateBase64Image } from "../utils/validators";
import { FieldValue } from "firebase-admin/firestore";

const SLIDERS_COLLECTION = "sliders";

export class SliderService {
  /**
   * Creates a new slider with image uploaded to Storage.
   */
  static async createSlider(input: CreateSliderInput): Promise<Slider> {
    validateRequiredString(input.judul, "judul");
    validateRequiredString(input.deskripsi, "deskripsi");
    validateBase64Image(input.gambar_base64);

    const docRef = db.collection(SLIDERS_COLLECTION).doc();
    const sliderUid = docRef.id;

    // Upload image to Storage
    const storagePath = `sliders/${sliderUid}/image_${Date.now()}.jpg`;
    const downloadUrl = await StorageService.uploadImage(
      input.gambar_base64,
      storagePath,
    );

    const sliderData = {
      uid: sliderUid,
      judul: input.judul,
      deskripsi: input.deskripsi,
      gambar: downloadUrl,
      gambar_path: storagePath,
      created_at: FieldValue.serverTimestamp(),
    };

    await docRef.set(sliderData);

    const doc = await docRef.get();
    return doc.data() as Slider;
  }

  /**
   * Deletes a slider and its image from Storage.
   */
  static async deleteSlider(uid: string): Promise<void> {
    const docRef = db.collection(SLIDERS_COLLECTION).doc(uid);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Slider with uid "${uid}" not found.`);
    }

    const data = doc.data() as Slider;

    // Delete image from Storage
    if (data.gambar_path) {
      await StorageService.deleteImage(data.gambar_path);
    }

    await docRef.delete();
  }
}
