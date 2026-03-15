import * as functionsV1 from "firebase-functions/v1";
import { UserService } from "../services/user.service";

/**
 * Auth trigger: onCreate
 * Automatically creates a user profile document in Firestore
 * when a new user registers via Firebase Auth.
 */
export const onUserCreated = functionsV1.auth.user().onCreate(async (user) => {
    const { uid, email, displayName } = user;

    console.log(`New user created: ${uid} (${email})`);

    try {
        await UserService.createUserProfile(
            uid,
            email || "",
            displayName || undefined,
        );

        console.log(`User profile created for: ${uid}`);
    } catch (error) {
        console.error(`Failed to create user profile for ${uid}:`, error);
    }
});
