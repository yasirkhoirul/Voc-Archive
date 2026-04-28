import * as crypto from "crypto";
import {
  db,
  midtransServerKey,
  midtransClientKey,
  midtransIsProduction,
} from "../config/firebase";
import {
  CreateTransactionInput,
  OrderHistoryItem,
  TransactionItem,
} from "../models/payment.model";
import { FieldValue } from "firebase-admin/firestore";
// eslint-disable-next-line @typescript-eslint/no-require-imports
const midtransClient = require("midtrans-client");

const ORDER_HISTORY_COLLECTION = "order_history";
const PRODUCTS_COLLECTION = "products";

function getSnapClient() {
  return new midtransClient.Snap({
    isProduction: midtransIsProduction.value() === "true",
    serverKey: midtransServerKey.value(),
    clientKey: midtransClientKey.value(),
  });
}

function getCoreApiClient() {
  return new midtransClient.CoreApi({
    isProduction: midtransIsProduction.value() === "true",
    serverKey: midtransServerKey.value(),
    clientKey: midtransClientKey.value(),
  });
}

/**
 * Verify Midtrans signature key to prevent spoofed notifications.
 * signature_key = SHA512(order_id + status_code + gross_amount + server_key)
 */
function verifySignature(notification: Record<string, unknown>): boolean {
  const orderId = notification.order_id as string;
  const statusCode = notification.status_code as string;
  const grossAmount = notification.gross_amount as string;
  const serverKey = midtransServerKey.value();

  if (!orderId || !statusCode || !grossAmount) return false;

  const payload = orderId + statusCode + grossAmount + serverKey;
  const expectedSignature = crypto
    .createHash("sha512")
    .update(payload)
    .digest("hex");

  return expectedSignature === (notification.signature_key as string);
}

function resolveStatus(
  transactionStatus: string,
  fraudStatus?: string
): string {
  if (transactionStatus === "capture") {
    return fraudStatus === "accept" ? "settlement" : "deny";
  } else if (transactionStatus === "settlement") {
    return "settlement";
  } else if (
    transactionStatus === "cancel" ||
    transactionStatus === "deny"
  ) {
    return "cancel";
  } else if (transactionStatus === "expire") {
    return "expire";
  }
  return "pending";
}

/**
 * Reduce stock for ordered items using Firestore transaction.
 * Each item's size stock is decremented by the ordered quantity.
 * Throws if stock is insufficient.
 */
async function reduceStock(items: TransactionItem[]): Promise<void> {
  await db.runTransaction(async (transaction) => {
    // Group items by product_id and aggregate quantities per size
    const productSizeMap: Record<string, Record<string, number>> = {};
    for (const item of items) {
      if (!productSizeMap[item.product_id]) {
        productSizeMap[item.product_id] = {};
      }
      const currentQty = productSizeMap[item.product_id][item.size] || 0;
      productSizeMap[item.product_id][item.size] = currentQty + item.quantity;
    }

    // Read all product docs inside transaction
    const productRefs: Record<string, FirebaseFirestore.DocumentReference> = {};
    const productDocs: Record<string, FirebaseFirestore.DocumentData> = {};

    for (const productId of Object.keys(productSizeMap)) {
      const ref = db.collection(PRODUCTS_COLLECTION).doc(productId);
      const doc = await transaction.get(ref);
      if (!doc.exists) {
        throw new Error(`Product "${productId}" not found for stock reduction.`);
      }
      productRefs[productId] = ref;
      productDocs[productId] = doc.data()!;
    }

    // Validate and reduce
    for (const [productId, sizeChanges] of Object.entries(productSizeMap)) {
      const product = productDocs[productId];
      const sizes = { ...product.sizes } as Record<string, number>;

      for (const [size, qty] of Object.entries(sizeChanges)) {
        const currentStock = sizes[size] ?? 0;
        if (currentStock < qty) {
          throw new Error(
            `Insufficient stock for product "${product.nama_brand || productId}" ` +
            `size "${size}". Available: ${currentStock}, Requested: ${qty}.`
          );
        }
        sizes[size] = currentStock - qty;
      }

      const totalStok = Object.values(sizes).reduce((sum, v) => sum + v, 0);

      transaction.update(productRefs[productId], {
        sizes,
        total_stok: totalStok,
        updated_at: FieldValue.serverTimestamp(),
      });
    }
  });
}

/**
 * Restore stock for items from a cancelled/expired/denied order.
 * Uses Firestore transaction for atomicity.
 */
async function restoreStock(items: OrderHistoryItem[]): Promise<void> {
  await db.runTransaction(async (transaction) => {
    // Group by product_id
    const productSizeMap: Record<string, Record<string, number>> = {};
    for (const item of items) {
      if (!productSizeMap[item.product_id]) {
        productSizeMap[item.product_id] = {};
      }
      const currentQty = productSizeMap[item.product_id][item.size] || 0;
      productSizeMap[item.product_id][item.size] = currentQty + item.quantity;
    }

    const productRefs: Record<string, FirebaseFirestore.DocumentReference> = {};
    const productDocs: Record<string, FirebaseFirestore.DocumentData> = {};

    for (const productId of Object.keys(productSizeMap)) {
      const ref = db.collection(PRODUCTS_COLLECTION).doc(productId);
      const doc = await transaction.get(ref);
      if (!doc.exists) {
        console.warn(`[RestoreStock] Product "${productId}" not found, skipping.`);
        continue;
      }
      productRefs[productId] = ref;
      productDocs[productId] = doc.data()!;
    }

    for (const [productId, sizeChanges] of Object.entries(productSizeMap)) {
      if (!productDocs[productId]) continue;

      const product = productDocs[productId];
      const sizes = { ...product.sizes } as Record<string, number>;

      for (const [size, qty] of Object.entries(sizeChanges)) {
        sizes[size] = (sizes[size] ?? 0) + qty;
      }

      const totalStok = Object.values(sizes).reduce((sum, v) => sum + v, 0);

      transaction.update(productRefs[productId], {
        sizes,
        total_stok: totalStok,
        updated_at: FieldValue.serverTimestamp(),
      });
    }
  });
}

export class PaymentService {
  /**
   * Creates a manual PayPal transaction
   */
  static async createPaypalManualTransaction(
    userId: string,
    input: CreateTransactionInput & { proof_url?: string }
  ) {
    if (!input.items || input.items.length === 0) {
      throw new Error("Items cannot be empty.");
    }
    if (!input.shipping_area) {
      throw new Error("Shipping area is required.");
    }
    if (!input.customer || !input.customer.email || !input.customer.name) {
      throw new Error("Customer info (name, email) is required.");
    }

    // Fetch exchange rate
    const exchangeDoc = await db.collection("settings").doc("exchange_rate").get();
    if (!exchangeDoc.exists) throw new Error("Exchange rate has not been configured.");
    const exchangeRate = exchangeDoc.data()?.usd_to_idr as number;
    if (!exchangeRate || exchangeRate <= 0) throw new Error("Invalid exchange rate.");

    // Fetch shipping rate
    const shippingDoc = await db.collection("settings").doc("shipping_rates").get();
    if (!shippingDoc.exists) throw new Error("Shipping rates have not been configured.");
    const shippingRates =
      (shippingDoc.data()?.rates as Array<{ nama_area: string; harga: number; }>) || [];
    const shippingRate = shippingRates.find((r) => r.nama_area.toLowerCase() === input.shipping_area.toLowerCase());
    if (!shippingRate) throw new Error(`Shipping rate for "${input.shipping_area}" not found.`);
    const shippingCostUsd = shippingRate.harga;
    const shippingCostIdr = Math.round(shippingCostUsd * exchangeRate);

    // Fetch products
    const productIds = [...new Set(input.items.map((i) => i.product_id))];
    const productMap: Record<string, FirebaseFirestore.DocumentData> = {};
    for (let i = 0; i < productIds.length; i += 10) {
      const batch = productIds.slice(i, i + 10);
      const snapshot = await db.collection("products").where("uid", "in", batch).get();
      for (const doc of snapshot.docs) productMap[doc.id] = doc.data();
    }

    const orderItems: OrderHistoryItem[] = [];
    let subtotalUsd = 0;

    for (const item of input.items) {
      const product = productMap[item.product_id];
      if (!product) throw new Error(`Product with ID ${item.product_id} not found.`);

      const originalPriceUsd = product.harga as number;
      const discountPercent = (product.diskon as number) || 0;
      const discountedPriceUsd = discountPercent > 0 ? (product.harga_diskon as number) : originalPriceUsd;

      const finalPriceUsd = discountedPriceUsd;
      const finalPriceIdr = Math.round(finalPriceUsd * exchangeRate);

      subtotalUsd += finalPriceUsd * item.quantity;
      orderItems.push({
        product_id: item.product_id,
        product_name: product.deskripsi || product.nama_brand || "Unknown",
        brand_name: product.nama_brand || "Unknown",
        size: item.size,
        quantity: item.quantity,
        price_usd: originalPriceUsd,
        discount_percent: discountPercent,
        final_price_usd: finalPriceUsd,
        final_price_idr: finalPriceIdr,
      });
    }

    const subtotalIdr = Math.round(subtotalUsd * exchangeRate);
    const totalUsd = subtotalUsd + shippingCostUsd;
    const totalIdr = subtotalIdr + shippingCostIdr;

    const orderId = `VOC-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

    // Reduce stock immediately (pending = reserved)
    await reduceStock(input.items);

    // Save order history as pending manual paypal
    await db.collection(ORDER_HISTORY_COLLECTION).doc(orderId).set({
      order_id: orderId,
      user_id: userId,
      status: "pending",
      payment_method: "paypal_manual",
      stock_reserved: true,
      items: orderItems,
      customer: input.customer,
      shipping_area: input.shipping_area,
      shipping_cost_usd: shippingCostUsd,
      shipping_cost_idr: shippingCostIdr,
      exchange_rate: exchangeRate,
      subtotal_usd: subtotalUsd,
      subtotal_idr: subtotalIdr,
      total_usd: totalUsd,
      total_idr: totalIdr,
      proof_url: input.proof_url || "",
      redirect_url: "",
      snap_token: "",
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    });

    return {
      order_id: orderId,
      status: "pending",
      total_idr: totalIdr,
      total_usd: totalUsd,
    };
  }

  /**
   * Creates a Midtrans Snap transaction.
   */
  static async createTransaction(
    userId: string,
    input: CreateTransactionInput
  ) {
    if (!input.items || input.items.length === 0) {
      throw new Error("Items cannot be empty.");
    }
    if (!input.shipping_area) {
      throw new Error("Shipping area is required.");
    }
    if (!input.customer || !input.customer.email || !input.customer.name) {
      throw new Error("Customer info (name, email) is required.");
    }

    // Fetch exchange rate
    const exchangeDoc = await db
      .collection("settings")
      .doc("exchange_rate")
      .get();
    if (!exchangeDoc.exists) {
      throw new Error("Exchange rate has not been configured.");
    }
    const exchangeRate = exchangeDoc.data()?.usd_to_idr as number;
    if (!exchangeRate || exchangeRate <= 0) {
      throw new Error("Invalid exchange rate.");
    }

    // Fetch shipping rate
    const shippingDoc = await db
      .collection("settings")
      .doc("shipping_rates")
      .get();
    if (!shippingDoc.exists) {
      throw new Error("Shipping rates have not been configured.");
    }
    const shippingRates =
      (shippingDoc.data()?.rates as Array<{
        nama_area: string;
        harga: number;
      }>) || [];
    const shippingRate = shippingRates.find(
      (r) => r.nama_area.toLowerCase() === input.shipping_area.toLowerCase()
    );
    if (!shippingRate) {
      throw new Error(
        `Shipping rate for "${input.shipping_area}" not found.`
      );
    }
    const shippingCostUsd = shippingRate.harga;
    const shippingCostIdr = Math.round(shippingCostUsd * exchangeRate);

    // Fetch product prices (server-side verification)
    const productIds = [...new Set(input.items.map((i) => i.product_id))];
    const productMap: Record<string, FirebaseFirestore.DocumentData> = {};

    for (let i = 0; i < productIds.length; i += 10) {
      const batch = productIds.slice(i, i + 10);
      const snapshot = await db
        .collection("products")
        .where("uid", "in", batch)
        .get();
      for (const doc of snapshot.docs) {
        productMap[doc.data().uid] = doc.data();
      }
    }

    // Calculate prices
    const orderItems: OrderHistoryItem[] = [];
    let subtotalUsd = 0;
    const midtransItems: Array<{
      id: string;
      price: number;
      quantity: number;
      name: string;
    }> = [];

    for (const item of input.items) {
      const product = productMap[item.product_id];
      if (!product) {
        throw new Error(`Product "${item.product_id}" not found.`);
      }

      const originalPriceUsd = product.harga as number;
      const discountPercent = (product.diskon as number) || 0;
      const discountedPriceUsd =
        discountPercent > 0
          ? (product.harga_diskon as number)
          : originalPriceUsd;

      const finalPriceUsd = discountedPriceUsd;
      const finalPriceIdr = Math.round(finalPriceUsd * exchangeRate);

      subtotalUsd += finalPriceUsd * item.quantity;

      orderItems.push({
        product_id: item.product_id,
        product_name: product.nama_brand || "",
        brand_name: product.nama_brand || "",
        size: item.size,
        quantity: item.quantity,
        price_usd: originalPriceUsd,
        discount_percent: discountPercent,
        final_price_usd: finalPriceUsd,
        final_price_idr: finalPriceIdr,
      });

      midtransItems.push({
        id: item.product_id.substring(0, 50),
        price: finalPriceIdr,
        quantity: item.quantity,
        name: `${product.nama_brand || "Product"} (${item.size})`.substring(
          0,
          50
        ),
      });
    }

    midtransItems.push({
      id: "SHIPPING",
      price: shippingCostIdr,
      quantity: 1,
      name: `Shipping - ${input.shipping_area}`,
    });

    const subtotalIdr = Math.round(subtotalUsd * exchangeRate);
    const totalUsd = subtotalUsd + shippingCostUsd;
    const totalIdr = subtotalIdr + shippingCostIdr;

    const orderId = `VOC-${Date.now()}-${Math.random()
      .toString(36)
      .substring(2, 8)
      .toUpperCase()}`;

    // Create Snap transaction
    const snap = getSnapClient();
    const snapResponse = await snap.createTransaction({
      transaction_details: {
        order_id: orderId,
        gross_amount: totalIdr,
      },
      item_details: midtransItems,
      customer_details: {
        first_name: input.customer.name,
        email: input.customer.email,
        phone: input.customer.phone,
        shipping_address: {
          first_name: input.customer.name,
          phone: input.customer.phone,
          city: input.customer.city,
          postal_code: input.customer.postal_code,
          address: input.customer.address,
        },
      },
    });

    const snapToken = snapResponse.token as string;
    const redirectUrl = snapResponse.redirect_url as string;

    // Reduce stock immediately (pending = reserved)
    await reduceStock(input.items);

    // Save order history
    await db.collection(ORDER_HISTORY_COLLECTION).doc(orderId).set({
      order_id: orderId,
      user_id: userId,
      status: "pending",
      payment_method: "midtrans",
      stock_reserved: true,
      items: orderItems,
      customer: input.customer,
      shipping_area: input.shipping_area,
      shipping_cost_usd: shippingCostUsd,
      shipping_cost_idr: shippingCostIdr,
      exchange_rate: exchangeRate,
      subtotal_usd: subtotalUsd,
      subtotal_idr: subtotalIdr,
      total_usd: totalUsd,
      total_idr: totalIdr,
      snap_token: snapToken,
      redirect_url: redirectUrl,
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    });

    return {
      order_id: orderId,
      snap_token: snapToken,
      redirect_url: redirectUrl,
      total_idr: totalIdr,
      total_usd: totalUsd,
    };
  }

  /**
   * Checks transaction status from Midtrans and updates Firestore.
   * Also handles stock restore for failed/expired/cancelled orders.
   */
  static async checkTransactionStatus(orderId: string) {
    const coreApi = getCoreApiClient();
    const statusResponse = await coreApi.transaction.status(orderId);

    const transactionStatus = statusResponse.transaction_status as string;
    const fraudStatus = statusResponse.fraud_status as string;
    const paymentType = statusResponse.payment_type as string;
    const status = resolveStatus(transactionStatus, fraudStatus);

    // Check if we need to restore stock
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();

    if (orderDoc.exists) {
      const orderData = orderDoc.data()!;
      const previousStatus = orderData.status as string;
      const stockReserved = orderData.stock_reserved as boolean;

      const failedStatuses = ["cancel", "expire", "deny"];
      const isNowFailed = failedStatuses.includes(status);
      const wasPreviouslyActive = !failedStatuses.includes(previousStatus);

      if (isNowFailed && wasPreviouslyActive && stockReserved) {
        try {
          const items = orderData.items as OrderHistoryItem[];
          await restoreStock(items);
          console.log(`[CheckStatus] Stock restored for order ${orderId}`);

          await orderRef.update({
            status,
            stock_reserved: false,
            payment_method: paymentType || "midtrans",
            midtrans_response: statusResponse,
            updated_at: FieldValue.serverTimestamp(),
          });
        } catch (restoreError) {
          console.error(
            `[CheckStatus] Failed to restore stock for ${orderId}:`,
            restoreError
          );
          await orderRef.update({
            status,
            stock_restore_failed: true,
            payment_method: paymentType || "midtrans",
            midtrans_response: statusResponse,
            updated_at: FieldValue.serverTimestamp(),
          });
        }
      } else {
        await orderRef.update({
          status,
          payment_method: paymentType || "midtrans",
          midtrans_response: statusResponse,
          updated_at: FieldValue.serverTimestamp(),
        });
      }
    }

    return {
      order_id: orderId,
      status,
      payment_type: paymentType,
      transaction_status: transactionStatus,
      fraud_status: fraudStatus,
    };
  }

  /**
   * Handles Midtrans webhook notification.
   * Verifies signature and updates order status in Firestore.
   *
   * Based on: https://docs.midtrans.com/docs/https-notification-webhooks
   *
   * Midtrans expects HTTP 200 response. Must respond quickly.
   */
  static async handleNotification(notificationBody: Record<string, unknown>) {
    const orderId = notificationBody.order_id as string;
    const transactionStatus =
      notificationBody.transaction_status as string;
    const fraudStatus = notificationBody.fraud_status as string;
    const paymentType = notificationBody.payment_type as string;

    console.log(
      `[Webhook] Received: order_id=${orderId}, ` +
        `transaction_status=${transactionStatus}, ` +
        `fraud_status=${fraudStatus}, payment_type=${paymentType}`
    );

    // If no order_id, it might be a test ping from Midtrans dashboard
    if (!orderId) {
      console.log("[Webhook] No order_id — likely a test notification.");
      return { status: "ok", message: "Test notification acknowledged." };
    }

    // Verify signature
    const isValid = verifySignature(notificationBody);
    if (!isValid) {
      console.error(`[Webhook] Invalid signature for order ${orderId}`);
      return { status: "error", message: "Invalid signature." };
    }

    // Resolve status
    const status = resolveStatus(transactionStatus, fraudStatus);

    // Update Firestore (if order exists)
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      console.error(`[Webhook] Order ${orderId} not found in Firestore.`);
      // Still return 200 so Midtrans doesn't retry
      return { status: "ok", message: "Order not found, acknowledged." };
    }

    const orderData = orderDoc.data()!;
    const previousStatus = orderData.status as string;
    const stockReserved = orderData.stock_reserved as boolean;

    // Stock restoration logic:
    // If payment failed/expired/cancelled AND stock was previously reserved → restore
    const failedStatuses = ["cancel", "expire", "deny"];
    const isNowFailed = failedStatuses.includes(status);
    const wasPreviouslyActive = !failedStatuses.includes(previousStatus);

    if (isNowFailed && wasPreviouslyActive && stockReserved) {
      try {
        const items = orderData.items as OrderHistoryItem[];
        await restoreStock(items);
        console.log(`[Webhook] Stock restored for order ${orderId}`);

        await orderRef.update({
          status,
          stock_reserved: false,
          payment_method: paymentType || "midtrans",
          midtrans_response: notificationBody,
          updated_at: FieldValue.serverTimestamp(),
        });
      } catch (restoreError) {
        console.error(
          `[Webhook] Failed to restore stock for order ${orderId}:`,
          restoreError
        );
        // Still update the status even if restore fails
        await orderRef.update({
          status,
          stock_restore_failed: true,
          payment_method: paymentType || "midtrans",
          midtrans_response: notificationBody,
          updated_at: FieldValue.serverTimestamp(),
        });
      }
    } else {
      await orderRef.update({
        status,
        payment_method: paymentType || "midtrans",
        midtrans_response: notificationBody,
        updated_at: FieldValue.serverTimestamp(),
      });
    }

    console.log(
      `[Webhook] Updated order ${orderId}: status=${status}, payment=${paymentType}`
    );

    return { status: "ok", order_id: orderId, transaction_status: status };
  }

  /**
   * Syncs all pending Midtrans orders by checking their status via Midtrans API.
   * PayPal orders are skipped (they require manual admin verification).
   * Called by admin when opening order history.
   *
   * Returns a summary of what was synced.
   */
  static async syncPendingMidtransOrders() {
    // Query all pending orders with midtrans payment method
    const snapshot = await db
      .collection(ORDER_HISTORY_COLLECTION)
      .where("status", "==", "pending")
      .where("payment_method", "==", "midtrans")
      .get();

    if (snapshot.empty) {
      console.log("[SyncPending] No pending Midtrans orders found.");
      return { synced: 0, results: [] };
    }

    console.log(
      `[SyncPending] Found ${snapshot.size} pending Midtrans orders to check.`
    );

    const results: Array<{
      order_id: string;
      previous_status: string;
      new_status: string;
      stock_restored: boolean;
      error?: string;
    }> = [];

    for (const doc of snapshot.docs) {
      const orderData = doc.data();
      const orderId = orderData.order_id as string;

      try {
        const coreApi = getCoreApiClient();
        const statusResponse = await coreApi.transaction.status(orderId);

        const transactionStatus =
          statusResponse.transaction_status as string;
        const fraudStatus = statusResponse.fraud_status as string;
        const paymentType = statusResponse.payment_type as string;
        const newStatus = resolveStatus(transactionStatus, fraudStatus);

        const stockReserved = orderData.stock_reserved as boolean;
        const failedStatuses = ["cancel", "expire", "deny"];
        const isNowFailed = failedStatuses.includes(newStatus);
        let stockRestored = false;

        if (isNowFailed && stockReserved) {
          // Restore stock
          try {
            const items = orderData.items as OrderHistoryItem[];
            await restoreStock(items);
            stockRestored = true;
            console.log(`[SyncPending] Stock restored for order ${orderId}`);

            await doc.ref.update({
              status: newStatus,
              stock_reserved: false,
              payment_method: paymentType || "midtrans",
              midtrans_response: statusResponse,
              updated_at: FieldValue.serverTimestamp(),
            });
          } catch (restoreError) {
            console.error(
              `[SyncPending] Failed to restore stock for ${orderId}:`,
              restoreError
            );
            await doc.ref.update({
              status: newStatus,
              stock_restore_failed: true,
              payment_method: paymentType || "midtrans",
              midtrans_response: statusResponse,
              updated_at: FieldValue.serverTimestamp(),
            });
          }
        } else if (newStatus !== "pending") {
          // Status changed but not failed (e.g., settlement)
          await doc.ref.update({
            status: newStatus,
            payment_method: paymentType || "midtrans",
            midtrans_response: statusResponse,
            updated_at: FieldValue.serverTimestamp(),
          });
        }
        // If still pending, do nothing

        results.push({
          order_id: orderId,
          previous_status: "pending",
          new_status: newStatus,
          stock_restored: stockRestored,
        });
      } catch (error) {
        const message =
          error instanceof Error ? error.message : "Unknown error";

        // If Midtrans returns 404, the user never selected a payment method.
        // Treat as expired and restore stock.
        const is404 = message.includes("404") || message.includes("not found");
        if (is404) {
          console.log(`[SyncPending] Order ${orderId} not found in Midtrans (404). Treating as expired.`);
          const stockReserved = orderData.stock_reserved as boolean;
          let stockRestored = false;

          if (stockReserved) {
            try {
              const items = orderData.items as OrderHistoryItem[];
              await restoreStock(items);
              stockRestored = true;
              console.log(`[SyncPending] Stock restored for abandoned order ${orderId}`);
            } catch (restoreErr) {
              console.error(`[SyncPending] Failed to restore stock for ${orderId}:`, restoreErr);
            }
          }

          await doc.ref.update({
            status: "expire",
            stock_reserved: stockRestored ? false : (orderData.stock_reserved ?? false),
            updated_at: FieldValue.serverTimestamp(),
          });

          results.push({
            order_id: orderId,
            previous_status: "pending",
            new_status: "expire",
            stock_restored: stockRestored,
          });
        } else {
          console.error(
            `[SyncPending] Failed to check order ${orderId}:`,
            message
          );
          results.push({
            order_id: orderId,
            previous_status: "pending",
            new_status: "error",
            stock_restored: false,
            error: message,
          });
        }
      }
    }

    const synced = results.filter((r) => r.new_status !== "pending" && r.new_status !== "error").length;
    console.log(
      `[SyncPending] Done. Checked: ${results.length}, Status changed: ${synced}`
    );

    return { synced, total_checked: results.length, results };
  }

  /**
   * Syncs pending Midtrans orders for a specific user.
   * Called when user opens their own order history.
   * Only checks orders belonging to the given userId.
   * PayPal orders are skipped.
   */
  static async syncUserPendingMidtransOrders(userId: string) {
    const snapshot = await db
      .collection(ORDER_HISTORY_COLLECTION)
      .where("user_id", "==", userId)
      .where("status", "==", "pending")
      .where("payment_method", "==", "midtrans")
      .get();

    if (snapshot.empty) {
      return { synced: 0, results: [] };
    }

    console.log(
      `[SyncUserPending] Found ${snapshot.size} pending Midtrans orders for user ${userId}.`
    );

    const results: Array<{
      order_id: string;
      new_status: string;
      stock_restored: boolean;
      error?: string;
    }> = [];

    for (const doc of snapshot.docs) {
      const orderData = doc.data();
      const orderId = orderData.order_id as string;

      try {
        const coreApi = getCoreApiClient();
        const statusResponse = await coreApi.transaction.status(orderId);

        const transactionStatus =
          statusResponse.transaction_status as string;
        const fraudStatus = statusResponse.fraud_status as string;
        const paymentType = statusResponse.payment_type as string;
        const newStatus = resolveStatus(transactionStatus, fraudStatus);

        const stockReserved = orderData.stock_reserved as boolean;
        const failedStatuses = ["cancel", "expire", "deny"];
        const isNowFailed = failedStatuses.includes(newStatus);
        let stockRestored = false;

        if (isNowFailed && stockReserved) {
          try {
            const items = orderData.items as OrderHistoryItem[];
            await restoreStock(items);
            stockRestored = true;
            console.log(`[SyncUserPending] Stock restored for order ${orderId}`);

            await doc.ref.update({
              status: newStatus,
              stock_reserved: false,
              payment_method: paymentType || "midtrans",
              midtrans_response: statusResponse,
              updated_at: FieldValue.serverTimestamp(),
            });
          } catch (restoreError) {
            console.error(
              `[SyncUserPending] Failed to restore stock for ${orderId}:`,
              restoreError
            );
            await doc.ref.update({
              status: newStatus,
              stock_restore_failed: true,
              payment_method: paymentType || "midtrans",
              midtrans_response: statusResponse,
              updated_at: FieldValue.serverTimestamp(),
            });
          }
        } else if (newStatus !== "pending") {
          await doc.ref.update({
            status: newStatus,
            payment_method: paymentType || "midtrans",
            midtrans_response: statusResponse,
            updated_at: FieldValue.serverTimestamp(),
          });
        }

        results.push({
          order_id: orderId,
          new_status: newStatus,
          stock_restored: stockRestored,
        });
      } catch (error) {
        const message =
          error instanceof Error ? error.message : "Unknown error";

        // If Midtrans returns 404, user never selected payment method.
        // Treat as expired and restore stock.
        const is404 = message.includes("404") || message.includes("not found");
        if (is404) {
          console.log(`[SyncUserPending] Order ${orderId} not found in Midtrans (404). Treating as expired.`);
          const stockReserved = orderData.stock_reserved as boolean;
          let stockRestored = false;

          if (stockReserved) {
            try {
              const items = orderData.items as OrderHistoryItem[];
              await restoreStock(items);
              stockRestored = true;
              console.log(`[SyncUserPending] Stock restored for abandoned order ${orderId}`);
            } catch (restoreErr) {
              console.error(`[SyncUserPending] Failed to restore stock for ${orderId}:`, restoreErr);
            }
          }

          await doc.ref.update({
            status: "expire",
            stock_reserved: stockRestored ? false : (orderData.stock_reserved ?? false),
            updated_at: FieldValue.serverTimestamp(),
          });

          results.push({
            order_id: orderId,
            new_status: "expire",
            stock_restored: stockRestored,
          });
        } else {
          console.error(
            `[SyncUserPending] Failed to check order ${orderId}:`,
            message
          );
          results.push({
            order_id: orderId,
            new_status: "error",
            stock_restored: false,
            error: message,
          });
        }
      }
    }

    const synced = results.filter(
      (r) => r.new_status !== "pending" && r.new_status !== "error"
    ).length;

    return { synced, total_checked: results.length, results };
  }

  /**
   * Admin confirms a PayPal manual order.
   * Sets status to "settlement". Stock remains reserved (already deducted).
   */
  static async confirmPaypalOrder(orderId: string) {
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw new Error(`Order "${orderId}" not found.`);
    }

    const orderData = orderDoc.data()!;
    if (orderData.payment_method !== "paypal_manual") {
      throw new Error("This order is not a PayPal manual order.");
    }
    if (orderData.status === "settlement") {
      throw new Error("This order has already been confirmed.");
    }

    await orderRef.update({
      status: "settlement",
      updated_at: FieldValue.serverTimestamp(),
    });

    return { order_id: orderId, status: "settlement" };
  }

  /**
   * Admin rejects a PayPal manual order.
   * Sets status to "cancel" and restores stock if it was reserved.
   */
  static async rejectPaypalOrder(orderId: string) {
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw new Error(`Order "${orderId}" not found.`);
    }

    const orderData = orderDoc.data()!;
    if (orderData.payment_method !== "paypal_manual") {
      throw new Error("This order is not a PayPal manual order.");
    }
    if (orderData.status === "cancel") {
      throw new Error("This order has already been rejected.");
    }

    const stockReserved = orderData.stock_reserved as boolean;

    if (stockReserved) {
      try {
        const items = orderData.items as OrderHistoryItem[];
        await restoreStock(items);
        console.log(`[RejectPaypal] Stock restored for order ${orderId}`);
      } catch (restoreError) {
        console.error(
          `[RejectPaypal] Failed to restore stock for ${orderId}:`,
          restoreError
        );
      }
    }

    await orderRef.update({
      status: "cancel",
      stock_reserved: false,
      updated_at: FieldValue.serverTimestamp(),
    });

    return { order_id: orderId, status: "cancel" };
  }
}
