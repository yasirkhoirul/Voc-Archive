import { onCall, HttpsError, onRequest } from "firebase-functions/v2/https";
import { PaymentService } from "../services/payment.service";
import { UserService } from "../services/user.service";
import { CreateTransactionInput } from "../models/payment.model";

/**
 * Callable: createXenditInvoice
 * Authenticated users only. Creates a Xendit invoice for IDR payment.
 */
export const createXenditInvoice = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }
  try {
    const input = request.data as CreateTransactionInput;
    const result = await PaymentService.createXenditInvoice(request.auth.uid, input);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("createXenditInvoice error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: createPaypalManualTransaction
 * Authenticated users only. Creates a PayPal manual transaction.
 */
export const createPaypalManualTransaction = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }
  try {
    const input = request.data as CreateTransactionInput & { proof_url?: string };
    const result = await PaymentService.createPaypalManualTransaction(request.auth.uid, input);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("createPaypalManualTransaction error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: checkXenditStatus
 * Authenticated users only. Checks Xendit invoice status.
 */
export const checkXenditStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }
  try {
    const orderId = request.data?.order_id as string;
    if (!orderId) throw new Error("order_id is required.");
    const result = await PaymentService.checkXenditInvoiceStatus(orderId);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("checkXenditStatus error:", message);
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * HTTP Endpoint: xenditWebhook
 * Public endpoint for Xendit payment notifications.
 * Xendit sends POST with JSON body.
 * Header: x-callback-token = webhook_token
 *
 * Set in Xendit Dashboard > Settings > Webhooks:
 * https://us-central1-voc-archive.cloudfunctions.net/xenditWebhook
 */
export const xenditWebhook = onRequest({ cors: false }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(200).json({ status: "ok", message: "Ignored non-POST." });
    return;
  }

  try {
    const callbackToken = (req.headers["x-callback-token"] as string) || "";
    console.log("[XenditWebhook] Incoming body:", JSON.stringify(req.body));
    const result = await PaymentService.handleXenditWebhook(req.body as Record<string, unknown>, callbackToken);
    if (!result.valid && result.valid !== undefined) {
      res.status(403).json({ status: "error", message: result.message });
      return;
    }
    res.status(200).json(result);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    console.error("xenditWebhook error:", message);
    res.status(200).json({ status: "ok", message: "Acknowledged with error: " + message });
  }
});

/**
 * Callable: syncPendingXenditOrders
 * Admin only. Checks all pending Xendit orders.
 */
export const syncPendingXenditOrders = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "User must be authenticated.");
  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) throw new HttpsError("permission-denied", "Only admin users can sync orders.");
  try {
    const result = await PaymentService.syncPendingXenditOrders();
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("internal", message);
  }
});

/**
 * Callable: syncUserPendingXenditOrders
 * Authenticated users. Syncs their own pending Xendit orders.
 */
export const syncUserPendingXenditOrders = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "User must be authenticated.");
  try {
    const result = await PaymentService.syncUserPendingXenditOrders(request.auth.uid);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("internal", message);
  }
});

/**
 * Callable: confirmPaypalOrder — Admin only.
 */
export const confirmPaypalOrder = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "User must be authenticated.");
  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) throw new HttpsError("permission-denied", "Only admin users can confirm orders.");
  try {
    const orderId = request.data?.order_id as string;
    if (!orderId) throw new Error("order_id is required.");
    const result = await PaymentService.confirmPaypalOrder(orderId);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});

/**
 * Callable: rejectPaypalOrder — Admin only.
 */
export const rejectPaypalOrder = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "User must be authenticated.");
  const isAdmin = await UserService.isAdmin(request.auth.uid);
  if (!isAdmin) throw new HttpsError("permission-denied", "Only admin users can reject orders.");
  try {
    const orderId = request.data?.order_id as string;
    if (!orderId) throw new Error("order_id is required.");
    const result = await PaymentService.rejectPaypalOrder(orderId);
    return { success: true, data: result };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error.";
    throw new HttpsError("invalid-argument", message);
  }
});
