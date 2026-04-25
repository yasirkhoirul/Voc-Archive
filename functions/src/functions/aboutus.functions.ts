import { onCall, HttpsError } from "firebase-functions/v2/https";
import { AboutUsService, UpdateAboutUsInput } from "../services/aboutus.service";
import { UserService } from "../services/user.service";

/**
 * Callable: getAboutUsContent
 * Public. Returns the about us content from Firestore.
 */
export const getAboutUsContent = onCall(async () => {
  try {
    const data = await AboutUsService.getAboutUs();
    return { success: true, data };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("getAboutUsContent error:", message);
    throw new HttpsError("internal", message);
  }
});

/**
 * Callable: updateAboutUsContent
 * Admin only. Updates the about us content including image uploads.
 */
export const updateAboutUsContent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) {
    throw new HttpsError(
      "permission-denied",
      "Only admin users can update About Us content."
    );
  }

  try {
    const input = request.data as UpdateAboutUsInput;
    const result = await AboutUsService.updateAboutUs(input);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("updateAboutUsContent error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});
