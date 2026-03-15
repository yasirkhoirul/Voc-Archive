import { db } from "../config/firebase";
import { UserProfile } from "../models/user.model";
import { FieldValue } from "firebase-admin/firestore";

const USERS_COLLECTION = "users";

export class UserService {
    /**
     * Creates a new user profile document in Firestore.
     * Called automatically when a new user registers via Firebase Auth.
     */
    static async createUserProfile(
        uid: string,
        email: string,
        displayName?: string,
    ): Promise<UserProfile> {
        const now = FieldValue.serverTimestamp();

        const userProfile: Omit<UserProfile, "created_at" | "updated_at"> & {
            created_at: FirebaseFirestore.FieldValue;
            updated_at: FirebaseFirestore.FieldValue;
        } = {
            uid,
            email,
            nama: displayName || "",
            phone: "",
            address: {
                country: "",
                city: "",
                postal_code: "",
                address_detail: "",
            },
            role: "user",
            created_at: now,
            updated_at: now,
        };

        await db.collection(USERS_COLLECTION).doc(uid).set(userProfile);

        // Return the profile (timestamps will be resolved by Firestore)
        const doc = await db.collection(USERS_COLLECTION).doc(uid).get();
        return doc.data() as UserProfile;
    }

    /**
     * Checks if a user has admin role.
     */
    static async isAdmin(uid: string): Promise<boolean> {
        const doc = await db.collection(USERS_COLLECTION).doc(uid).get();
        if (!doc.exists) return false;
        const data = doc.data();
        return data?.role === "admin";
    }
}
