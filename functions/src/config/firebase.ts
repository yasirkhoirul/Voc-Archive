import * as dotenv from "dotenv";
dotenv.config();

import * as admin from "firebase-admin";
import { defineString } from "firebase-functions/params";

const app = admin.initializeApp();

export const db = admin.firestore(app);
export const auth = admin.auth(app);
export const storage = admin.storage(app);

// Secret params — these are set via `firebase functions:secrets:set`
// or fallback to .env for local development
export const midtransServerKey = defineString("MIDTRANS_SERVER_KEY", {
  default: process.env.MIDTRANS_SERVER_KEY || "",
});
export const midtransClientKey = defineString("MIDTRANS_CLIENT_KEY", {
  default: process.env.MIDTRANS_CLIENT_KEY || "",
});
export const midtransIsProduction = defineString("MIDTRANS_IS_PRODUCTION", {
  default: process.env.MIDTRANS_IS_PRODUCTION || "false",
});
