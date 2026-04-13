import { db } from "../config/firebase";
import {
  ShippingRate,
  ShippingRatesDoc,
  ExchangeRate,
} from "../models/settings.model";
import {
  validateRequiredString,
  validateNonNegativeNumber,
} from "../utils/validators";
import { FieldValue } from "firebase-admin/firestore";

const SETTINGS_COLLECTION = "settings";
const EXCHANGE_RATE_DOC = "exchange_rate";
const SHIPPING_RATES_DOC = "shipping_rates";

export class SettingsService {
  // ==========================================
  // Exchange Rate
  // ==========================================

  /**
   * Gets the current exchange rate.
   */
  static async getExchangeRate(): Promise<ExchangeRate | null> {
    const doc = await db.collection(SETTINGS_COLLECTION).doc(EXCHANGE_RATE_DOC).get();
    if (!doc.exists) return null;
    return doc.data() as ExchangeRate;
  }

  /**
   * Sets the USD to IDR exchange rate.
   */
  static async setExchangeRate(usdToIdr: number): Promise<ExchangeRate> {
    validateNonNegativeNumber(usdToIdr, "usd_to_idr");

    if (usdToIdr <= 0) {
      throw new Error("Exchange rate must be greater than 0.");
    }

    const data = {
      usd_to_idr: usdToIdr,
      updated_at: FieldValue.serverTimestamp(),
    };

    await db.collection(SETTINGS_COLLECTION).doc(EXCHANGE_RATE_DOC).set(data);

    const doc = await db.collection(SETTINGS_COLLECTION).doc(EXCHANGE_RATE_DOC).get();
    return doc.data() as ExchangeRate;
  }

  // ==========================================
  // Shipping Rates
  // ==========================================

  /**
   * Gets all shipping rates.
   */
  static async getShippingRates(): Promise<ShippingRate[]> {
    const doc = await db.collection(SETTINGS_COLLECTION).doc(SHIPPING_RATES_DOC).get();
    if (!doc.exists) return [];
    const data = doc.data() as ShippingRatesDoc;
    return data.rates || [];
  }

  /**
   * Adds a new shipping rate for an area.
   */
  static async addShippingRate(namaArea: string, harga: number): Promise<ShippingRate[]> {
    validateRequiredString(namaArea, "nama_area");
    validateNonNegativeNumber(harga, "harga");

    const docRef = db.collection(SETTINGS_COLLECTION).doc(SHIPPING_RATES_DOC);
    const doc = await docRef.get();

    let rates: ShippingRate[] = [];
    if (doc.exists) {
      const data = doc.data() as ShippingRatesDoc;
      rates = data.rates || [];
    }

    // Check for duplicate area name
    const exists = rates.some(
      (r) => r.nama_area.toLowerCase() === namaArea.toLowerCase()
    );
    if (exists) {
      throw new Error(`Shipping rate for "${namaArea}" already exists.`);
    }

    rates.push({ nama_area: namaArea, harga });

    await docRef.set({
      rates,
      updated_at: FieldValue.serverTimestamp(),
    });

    return rates;
  }

  /**
   * Updates the price for an existing shipping area.
   */
  static async updateShippingRate(namaArea: string, harga: number): Promise<ShippingRate[]> {
    validateRequiredString(namaArea, "nama_area");
    validateNonNegativeNumber(harga, "harga");

    const docRef = db.collection(SETTINGS_COLLECTION).doc(SHIPPING_RATES_DOC);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error("No shipping rates found.");
    }

    const data = doc.data() as ShippingRatesDoc;
    const rates = data.rates || [];

    const index = rates.findIndex(
      (r) => r.nama_area.toLowerCase() === namaArea.toLowerCase()
    );
    if (index === -1) {
      throw new Error(`Shipping rate for "${namaArea}" not found.`);
    }

    rates[index].harga = harga;

    await docRef.update({
      rates,
      updated_at: FieldValue.serverTimestamp(),
    });

    return rates;
  }

  /**
   * Deletes a shipping rate by area name.
   */
  static async deleteShippingRate(namaArea: string): Promise<ShippingRate[]> {
    validateRequiredString(namaArea, "nama_area");

    const docRef = db.collection(SETTINGS_COLLECTION).doc(SHIPPING_RATES_DOC);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error("No shipping rates found.");
    }

    const data = doc.data() as ShippingRatesDoc;
    const rates = data.rates || [];

    const filtered = rates.filter(
      (r) => r.nama_area.toLowerCase() !== namaArea.toLowerCase()
    );

    if (filtered.length === rates.length) {
      throw new Error(`Shipping rate for "${namaArea}" not found.`);
    }

    await docRef.update({
      rates: filtered,
      updated_at: FieldValue.serverTimestamp(),
    });

    return filtered;
  }
}
