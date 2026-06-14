import * as dotenv from "dotenv";
dotenv.config();

import * as admin from "firebase-admin";
import { defineString } from "firebase-functions/params";

const app = admin.initializeApp();

export const db = admin.firestore(app);
export const auth = admin.auth(app);
export const storage = admin.storage(app);

// Xendit secrets — set via `firebase functions:secrets:set`
// or fallback to .env for local development
export const xenditSecretKey = defineString("XENDIT_SECRET_KEY", {
  default: process.env.XENDIT_SECRET_KEY || "",
});
export const xenditWebhookToken = defineString("XENDIT_WEBHOOK_TOKEN", {
  default: process.env.XENDIT_WEBHOOK_TOKEN || "",
});
