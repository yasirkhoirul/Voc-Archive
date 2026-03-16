import { onCall, HttpsError } from "firebase-functions/v2/https";
import { SliderService } from "../services/slider.service";
import { UserService } from "../services/user.service";
import { CreateSliderInput, DeleteSliderInput } from "../models/slider.model";

/**
 * Callable function: createSlider
 * Only accessible by admin users.
 * Uploads image to Storage and creates slider document.
 */
export const createSlider = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can create sliders.");
  }

  try {
    const input = request.data as CreateSliderInput;
    const slider = await SliderService.createSlider(input);
    return { success: true, data: slider };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error occurred.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable function: deleteSlider
 * Only accessible by admin users.
 * Deletes slider document and its image from Storage.
 */
export const deleteSlider = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Only admin users can delete sliders.");
  }

  try {
    const input = request.data as DeleteSliderInput;

    if (!input.uid) {
      throw new Error("Slider uid is required.");
    }

    await SliderService.deleteSlider(input.uid);
    return { success: true };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error occurred.";
    throw new HttpsError("invalid-argument", message);
  }
});
