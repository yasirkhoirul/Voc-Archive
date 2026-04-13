import { onCall, HttpsError } from "firebase-functions/v2/https";
import { BrandService } from "../services/brand.service";
import { UserService } from "../services/user.service";
import {
  CreateBrandInput,
  UpdateBrandInput,
  DeleteBrandInput,
} from "../models/brand.model";

/**
 * Callable: createBrand
 * Admin only.
 */
export const createBrand = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can create brands.");
  }

  try {
    const input = request.data as CreateBrandInput;
    const brand = await BrandService.createBrand(input.nama);
    return { success: true, data: brand };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: updateBrand
 * Admin only.
 */
export const updateBrand = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can update brands.");
  }

  try {
    const input = request.data as UpdateBrandInput;
    const brand = await BrandService.updateBrand(input.uid, input.nama);
    return { success: true, data: brand };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: deleteBrand
 * Admin only.
 */
export const deleteBrand = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can delete brands.");
  }

  try {
    const input = request.data as DeleteBrandInput;

    if (!input.uid) {
      throw new Error("Brand uid is required.");
    }

    await BrandService.deleteBrand(input.uid);
    return { success: true };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});
