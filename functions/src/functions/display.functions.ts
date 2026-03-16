import { onCall, HttpsError } from "firebase-functions/v2/https";
import { DisplayService } from "../services/display.service";
import { UserService } from "../services/user.service";
import {
  CreateDisplayInput,
  UpdateDisplayInput,
  DeleteDisplayInput,
} from "../models/display.model";

/**
 * Callable function: createDisplay
 * Only accessible by admin users.
 * Creates a display item (e.g. "Recommended Items") with max 5 product IDs.
 */
export const createDisplay = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can create display items.");
  }

  try {
    const input = request.data as CreateDisplayInput;
    const display = await DisplayService.createDisplay(input);
    return { success: true, data: display };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error occurred.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable function: updateDisplay
 * Only accessible by admin users.
 */
export const updateDisplay = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can update display items.");
  }

  try {
    const input = request.data as UpdateDisplayInput;

    if (!input.uid) {
      throw new Error("Display item uid is required.");
    }

    const display = await DisplayService.updateDisplay(input);
    return { success: true, data: display };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error occurred.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable function: deleteDisplay
 * Only accessible by admin users.
 */
export const deleteDisplay = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can delete display items.");
  }

  try {
    const input = request.data as DeleteDisplayInput;

    if (!input.uid) {
      throw new Error("Display item uid is required.");
    }

    await DisplayService.deleteDisplay(input.uid);
    return { success: true };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error occurred.";
    throw new HttpsError("invalid-argument", message);
  }
});
