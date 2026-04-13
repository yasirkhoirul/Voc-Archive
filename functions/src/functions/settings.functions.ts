import { onCall, HttpsError } from "firebase-functions/v2/https";
import { SettingsService } from "../services/settings.service";
import { UserService } from "../services/user.service";
import {
  SetExchangeRateInput,
  AddShippingRateInput,
  UpdateShippingRateInput,
  DeleteShippingRateInput,
} from "../models/settings.model";

/**
 * Callable: setExchangeRate
 * Admin only. Sets the USD to IDR exchange rate.
 */
export const setExchangeRate = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can set exchange rate.");
  }

  try {
    const input = request.data as SetExchangeRateInput;

    if (!input.usd_to_idr) {
      throw new Error("usd_to_idr is required.");
    }

    const result = await SettingsService.setExchangeRate(input.usd_to_idr);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: addShippingRate
 * Admin only. Adds a new shipping rate for an area.
 */
export const addShippingRate = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can manage shipping rates.");
  }

  try {
    const input = request.data as AddShippingRateInput;
    const rates = await SettingsService.addShippingRate(input.nama_area, input.harga);
    return { success: true, data: rates };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: updateShippingRate
 * Admin only. Updates an existing shipping rate.
 */
export const updateShippingRate = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can manage shipping rates.");
  }

  try {
    const input = request.data as UpdateShippingRateInput;
    const rates = await SettingsService.updateShippingRate(input.nama_area, input.harga);
    return { success: true, data: rates };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: deleteShippingRate
 * Admin only. Removes a shipping rate by area name.
 */
export const deleteShippingRate = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can manage shipping rates.");
  }

  try {
    const input = request.data as DeleteShippingRateInput;

    if (!input.nama_area) {
      throw new Error("nama_area is required.");
    }

    const rates = await SettingsService.deleteShippingRate(input.nama_area);
    return { success: true, data: rates };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});
