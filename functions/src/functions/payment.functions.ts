import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onRequest } from "firebase-functions/v2/https";
import { PaymentService } from "../services/payment.service";
import { CreateTransactionInput } from "../models/payment.model";

/**
 * Callable: createMidtransTransaction
 * Authenticated users only. Creates a Snap transaction.
 */
export const createMidtransTransaction = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  try {
    const input = request.data as CreateTransactionInput;
    const result = await PaymentService.createTransaction(
      request.auth.uid,
      input
    );
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("createMidtransTransaction error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: createPaypalManualTransaction
 * Authenticated users only. Creates a Paypal manual transaction mapping to pending state.
 */
export const createPaypalManualTransaction = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  try {
    const input = request.data as CreateTransactionInput & { proof_url?: string };
    const result = await PaymentService.createPaypalManualTransaction(
      request.auth.uid,
      input
    );
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("createPaypalManualTransaction error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: checkMidtransStatus
 * Authenticated users only. Checks transaction status.
 */
export const checkMidtransStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  try {
    const orderId = request.data?.order_id as string;
    if (!orderId) {
      throw new Error("order_id is required.");
    }

    const result = await PaymentService.checkTransactionStatus(orderId);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("checkMidtransStatus error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * HTTP Endpoint: midtransWebhook
 * Public endpoint for Midtrans payment notifications.
 *
 * Midtrans sends POST with JSON body containing notification data.
 * This endpoint MUST:
 * - Accept POST requests
 * - Return HTTP 200 immediately
 * - Not require any auth headers
 *
 * Set in Midtrans Dashboard > Settings > Payment Notification URL:
 * https://us-central1-voc-archive.cloudfunctions.net/midtransWebhook
 */
export const midtransWebhook = onRequest(
  { cors: true },
  async (req, res) => {
    // Always respond 200 to Midtrans (even on errors)
    // so it doesn't keep retrying
    if (req.method !== "POST") {
      res.status(200).json({ status: "ok", message: "Method not POST, ignored." });
      return;
    }

    try {
      console.log("[Webhook] Incoming notification body:", JSON.stringify(req.body));
      const notificationBody = req.body as Record<string, unknown>;
      const result = await PaymentService.handleNotification(notificationBody);
      res.status(200).json(result);
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Unknown error.";
      console.error("midtransWebhook error:", message);
      // Still return 200 to prevent Midtrans from retrying
      res.status(200).json({ status: "ok", message: "Acknowledged with error: " + message });
    }
  }
);
