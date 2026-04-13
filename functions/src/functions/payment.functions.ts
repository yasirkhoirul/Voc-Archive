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
 * Public endpoint for Midtrans to send payment notifications.
 * Set this URL in Midtrans Dashboard > Settings > Payment Notification URL
 */
export const midtransWebhook = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  try {
    const notificationBody = req.body as Record<string, unknown>;
    const result = await PaymentService.handleNotification(notificationBody);
    res.status(200).json(result);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("midtransWebhook error:", message);
    res.status(500).json({ status: "error", message });
  }
});
