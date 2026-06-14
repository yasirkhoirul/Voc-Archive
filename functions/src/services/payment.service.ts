import axios from "axios";
import {
  db,
  xenditSecretKey,
  xenditWebhookToken,
} from "../config/firebase";
import {
  CreateTransactionInput,
  OrderHistoryItem,
  TransactionItem,
} from "../models/payment.model";
import { FieldValue } from "firebase-admin/firestore";

const ORDER_HISTORY_COLLECTION = "order_history";
const PRODUCTS_COLLECTION = "products";
const XENDIT_BASE_URL = "https://api.xendit.co";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function getXenditHeaders() {
  const key = xenditSecretKey.value();
  const encoded = Buffer.from(`${key}:`).toString("base64");
  return {
    Authorization: `Basic ${encoded}`,
    "Content-Type": "application/json",
  };
}

/** Maps Xendit invoice status → internal status */
function resolveXenditStatus(xenditStatus: string): string {
  const s = xenditStatus.toUpperCase();
  if (s === "PAID" || s === "SETTLED") return "settlement";
  if (s === "EXPIRED") return "expire";
  return "pending";
}

// ─── Stock helpers ────────────────────────────────────────────────────────────

async function reduceStock(items: TransactionItem[]): Promise<void> {
  await db.runTransaction(async (transaction) => {
    const productSizeMap: Record<string, Record<string, number>> = {};
    for (const item of items) {
      if (!productSizeMap[item.product_id]) productSizeMap[item.product_id] = {};
      const cur = productSizeMap[item.product_id][item.size] || 0;
      productSizeMap[item.product_id][item.size] = cur + item.quantity;
    }

    const productRefs: Record<string, FirebaseFirestore.DocumentReference> = {};
    const productDocs: Record<string, FirebaseFirestore.DocumentData> = {};

    for (const productId of Object.keys(productSizeMap)) {
      const ref = db.collection(PRODUCTS_COLLECTION).doc(productId);
      const doc = await transaction.get(ref);
      if (!doc.exists) throw new Error(`Product "${productId}" not found.`);
      productRefs[productId] = ref;
      productDocs[productId] = doc.data()!;
    }

    for (const [productId, sizeChanges] of Object.entries(productSizeMap)) {
      const product = productDocs[productId];
      const sizes = { ...product.sizes } as Record<string, number>;
      for (const [size, qty] of Object.entries(sizeChanges)) {
        const current = sizes[size] ?? 0;
        if (current < qty) throw new Error(`Insufficient stock: ${product.nama_brand} size ${size}.`);
        sizes[size] = current - qty;
      }
      const totalStok = Object.values(sizes).reduce((s, v) => s + v, 0);
      transaction.update(productRefs[productId], { sizes, total_stok: totalStok, updated_at: FieldValue.serverTimestamp() });
    }
  });
}

async function restoreStock(items: OrderHistoryItem[]): Promise<void> {
  await db.runTransaction(async (transaction) => {
    const productSizeMap: Record<string, Record<string, number>> = {};
    for (const item of items) {
      if (!productSizeMap[item.product_id]) productSizeMap[item.product_id] = {};
      const cur = productSizeMap[item.product_id][item.size] || 0;
      productSizeMap[item.product_id][item.size] = cur + item.quantity;
    }

    const productRefs: Record<string, FirebaseFirestore.DocumentReference> = {};
    const productDocs: Record<string, FirebaseFirestore.DocumentData> = {};

    for (const productId of Object.keys(productSizeMap)) {
      const ref = db.collection(PRODUCTS_COLLECTION).doc(productId);
      const doc = await transaction.get(ref);
      if (!doc.exists) { console.warn(`[RestoreStock] Product "${productId}" not found, skipping.`); continue; }
      productRefs[productId] = ref;
      productDocs[productId] = doc.data()!;
    }

    for (const [productId, sizeChanges] of Object.entries(productSizeMap)) {
      if (!productDocs[productId]) continue;
      const sizes = { ...productDocs[productId].sizes } as Record<string, number>;
      for (const [size, qty] of Object.entries(sizeChanges)) {
        sizes[size] = (sizes[size] ?? 0) + qty;
      }
      const totalStok = Object.values(sizes).reduce((s, v) => s + v, 0);
      transaction.update(productRefs[productId], { sizes, total_stok: totalStok, updated_at: FieldValue.serverTimestamp() });
    }
  });
}

// ─── Shared order builder ─────────────────────────────────────────────────────

async function buildOrderData(input: CreateTransactionInput) {
  const exchangeDoc = await db.collection("settings").doc("exchange_rate").get();
  if (!exchangeDoc.exists) throw new Error("Exchange rate not configured.");
  const exchangeRate = exchangeDoc.data()?.usd_to_idr as number;
  if (!exchangeRate || exchangeRate <= 0) throw new Error("Invalid exchange rate.");

  const shippingDoc = await db.collection("settings").doc("shipping_rates").get();
  if (!shippingDoc.exists) throw new Error("Shipping rates not configured.");
  const shippingRates = (shippingDoc.data()?.rates as Array<{ nama_area: string; harga: number }>) || [];
  const shippingRate = shippingRates.find((r) => r.nama_area.toLowerCase() === input.shipping_area.toLowerCase());
  if (!shippingRate) throw new Error(`Shipping rate for "${input.shipping_area}" not found.`);

  const shippingCostUsd = shippingRate.harga;
  const shippingCostIdr = Math.round(shippingCostUsd * exchangeRate);

  const productIds = [...new Set(input.items.map((i) => i.product_id))];
  const productMap: Record<string, FirebaseFirestore.DocumentData> = {};
  for (let i = 0; i < productIds.length; i += 10) {
    const batch = productIds.slice(i, i + 10);
    const snap = await db.collection("products").where("uid", "in", batch).get();
    for (const doc of snap.docs) productMap[doc.data().uid] = doc.data();
  }

  const orderItems: OrderHistoryItem[] = [];
  let subtotalUsd = 0;

  for (const item of input.items) {
    const product = productMap[item.product_id];
    if (!product) throw new Error(`Product "${item.product_id}" not found.`);
    const originalPriceUsd = product.harga as number;
    const discountPercent = (product.diskon as number) || 0;
    const finalPriceUsd = discountPercent > 0 ? (product.harga_diskon as number) : originalPriceUsd;
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

  return { exchangeRate, shippingCostUsd, shippingCostIdr, orderItems, subtotalUsd, subtotalIdr, totalUsd, totalIdr, orderId };
}

// ─── PaymentService ───────────────────────────────────────────────────────────

export class PaymentService {

  /** Creates a Xendit Invoice for IDR domestic payment */
  static async createXenditInvoice(userId: string, input: CreateTransactionInput) {
    if (!input.items || input.items.length === 0) throw new Error("Items cannot be empty.");
    if (!input.shipping_area) throw new Error("Shipping area is required.");
    if (!input.customer?.email || !input.customer?.name) throw new Error("Customer name and email are required.");

    const { exchangeRate, shippingCostUsd, shippingCostIdr, orderItems, subtotalUsd, subtotalIdr, totalUsd, totalIdr, orderId } =
      await buildOrderData(input);

    // Create Xendit invoice via REST API
    const invoicePayload = {
      external_id: orderId,
      amount: totalIdr,
      description: `voc.archive order ${orderId}`,
      invoice_duration: 86400, // 24 hours
      customer: {
        given_names: input.customer.name,
        email: input.customer.email,
        mobile_number: input.customer.phone || "",
      },
      customer_notification_preference: {
        invoice_created: ["email"],
        invoice_reminder: ["email"],
        invoice_paid: ["email"],
      },
      currency: "IDR",
      success_redirect_url: "https://voc-archive.vercel.app/payment-success",
      failure_redirect_url: "https://voc-archive.vercel.app/payment-failed",
    };

    const response = await axios.post(`${XENDIT_BASE_URL}/v2/invoices`, invoicePayload, {
      headers: getXenditHeaders(),
    });

    const xenditData = response.data as Record<string, unknown>;
    const invoiceUrl = xenditData.invoice_url as string;
    const xenditId = xenditData.id as string;

    // Reserve stock
    await reduceStock(input.items);

    // Save to Firestore
    await db.collection(ORDER_HISTORY_COLLECTION).doc(orderId).set({
      order_id: orderId,
      user_id: userId,
      status: "pending",
      payment_method: "xendit",
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
      invoice_url: invoiceUrl,
      xendit_invoice_id: xenditId,
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    });

    return { order_id: orderId, invoice_url: invoiceUrl, total_idr: totalIdr, total_usd: totalUsd };
  }

  /** Check Xendit invoice status and sync Firestore */
  static async checkXenditInvoiceStatus(orderId: string) {
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();
    if (!orderDoc.exists) throw new Error(`Order "${orderId}" not found.`);

    const orderData = orderDoc.data()!;
    const xenditId = orderData.xendit_invoice_id as string;
    if (!xenditId) throw new Error("No Xendit invoice ID for this order.");

    const response = await axios.get(`${XENDIT_BASE_URL}/v2/invoices/${xenditId}`, {
      headers: getXenditHeaders(),
    });

    const xenditData = response.data as Record<string, unknown>;
    const xenditStatus = xenditData.status as string;
    const status = resolveXenditStatus(xenditStatus);

    const failedStatuses = ["expire", "cancel"];
    const isNowFailed = failedStatuses.includes(status);
    const stockReserved = orderData.stock_reserved as boolean;

    if (isNowFailed && stockReserved) {
      try {
        await restoreStock(orderData.items as OrderHistoryItem[]);
        await orderRef.update({ status, stock_reserved: false, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
      } catch {
        await orderRef.update({ status, stock_restore_failed: true, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
      }
    } else {
      await orderRef.update({ status, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
    }

    return { order_id: orderId, status, xendit_status: xenditStatus };
  }

  /** Handle Xendit webhook POST (verifies callback token) */
  static async handleXenditWebhook(
    body: Record<string, unknown>,
    callbackToken: string
  ) {
    // Verify webhook token
    const expectedToken = xenditWebhookToken.value();
    if (callbackToken !== expectedToken) {
      console.error("[XenditWebhook] Invalid callback token.");
      return { valid: false, message: "Invalid token." };
    }

    const externalId = body.external_id as string;
    const xenditStatus = body.status as string;

    console.log(`[XenditWebhook] external_id=${externalId}, status=${xenditStatus}`);

    if (!externalId) {
      console.log("[XenditWebhook] No external_id — ignoring.");
      return { status: "ok", message: "No external_id." };
    }

    // external_id is our orderId
    const orderId = externalId;
    const status = resolveXenditStatus(xenditStatus);

    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      console.warn(`[XenditWebhook] Order ${orderId} not found.`);
      return { status: "ok", message: "Order not found, acknowledged." };
    }

    const orderData = orderDoc.data()!;
    const previousStatus = orderData.status as string;
    const stockReserved = orderData.stock_reserved as boolean;
    const failedStatuses = ["expire", "cancel"];
    const isNowFailed = failedStatuses.includes(status);
    const wasPreviouslyActive = !failedStatuses.includes(previousStatus) && previousStatus !== "settlement";

    if (isNowFailed && wasPreviouslyActive && stockReserved) {
      try {
        await restoreStock(orderData.items as OrderHistoryItem[]);
        await orderRef.update({ status, stock_reserved: false, xendit_response: body, updated_at: FieldValue.serverTimestamp() });
        console.log(`[XenditWebhook] Stock restored for ${orderId}`);
      } catch (e) {
        await orderRef.update({ status, stock_restore_failed: true, xendit_response: body, updated_at: FieldValue.serverTimestamp() });
        console.error(`[XenditWebhook] Restore failed for ${orderId}:`, e);
      }
    } else {
      await orderRef.update({ status, xendit_response: body, updated_at: FieldValue.serverTimestamp() });
    }

    console.log(`[XenditWebhook] Updated order ${orderId}: ${previousStatus} → ${status}`);
    return { status: "ok", order_id: orderId, new_status: status };
  }

  /** Admin sync all pending xendit orders */
  static async syncPendingXenditOrders() {
    const snapshot = await db
      .collection(ORDER_HISTORY_COLLECTION)
      .where("status", "==", "pending")
      .where("payment_method", "==", "xendit")
      .get();

    if (snapshot.empty) return { synced: 0, results: [] };

    const results: Array<{ order_id: string; new_status: string; stock_restored: boolean; error?: string }> = [];

    for (const doc of snapshot.docs) {
      const orderData = doc.data();
      const orderId = orderData.order_id as string;
      const xenditId = orderData.xendit_invoice_id as string;

      try {
        const response = await axios.get(`${XENDIT_BASE_URL}/v2/invoices/${xenditId}`, { headers: getXenditHeaders() });
        const xenditData = response.data as Record<string, unknown>;
        const newStatus = resolveXenditStatus(xenditData.status as string);

        const stockReserved = orderData.stock_reserved as boolean;
        const failedStatuses = ["expire", "cancel"];
        const isNowFailed = failedStatuses.includes(newStatus);
        let stockRestored = false;

        if (isNowFailed && stockReserved) {
          try {
            await restoreStock(orderData.items as OrderHistoryItem[]);
            stockRestored = true;
            await doc.ref.update({ status: newStatus, stock_reserved: false, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
          } catch {
            await doc.ref.update({ status: newStatus, stock_restore_failed: true, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
          }
        } else if (newStatus !== "pending") {
          await doc.ref.update({ status: newStatus, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
        }

        results.push({ order_id: orderId, new_status: newStatus, stock_restored: stockRestored });
      } catch (error) {
        const message = error instanceof Error ? error.message : "Unknown";
        console.error(`[SyncPending] Failed for ${orderId}:`, message);
        results.push({ order_id: orderId, new_status: "error", stock_restored: false, error: message });
      }
    }

    const synced = results.filter((r) => r.new_status !== "pending" && r.new_status !== "error").length;
    return { synced, total_checked: results.length, results };
  }

  /** User sync their own pending xendit orders */
  static async syncUserPendingXenditOrders(userId: string) {
    const snapshot = await db
      .collection(ORDER_HISTORY_COLLECTION)
      .where("user_id", "==", userId)
      .where("status", "==", "pending")
      .where("payment_method", "==", "xendit")
      .get();

    if (snapshot.empty) return { synced: 0, results: [] };

    const results: Array<{ order_id: string; new_status: string; stock_restored: boolean; error?: string }> = [];

    for (const doc of snapshot.docs) {
      const orderData = doc.data();
      const orderId = orderData.order_id as string;
      const xenditId = orderData.xendit_invoice_id as string;

      try {
        const response = await axios.get(`${XENDIT_BASE_URL}/v2/invoices/${xenditId}`, { headers: getXenditHeaders() });
        const xenditData = response.data as Record<string, unknown>;
        const newStatus = resolveXenditStatus(xenditData.status as string);

        const stockReserved = orderData.stock_reserved as boolean;
        const failedStatuses = ["expire", "cancel"];
        const isNowFailed = failedStatuses.includes(newStatus);
        let stockRestored = false;

        if (isNowFailed && stockReserved) {
          try {
            await restoreStock(orderData.items as OrderHistoryItem[]);
            stockRestored = true;
            await doc.ref.update({ status: newStatus, stock_reserved: false, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
          } catch {
            await doc.ref.update({ status: newStatus, stock_restore_failed: true, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
          }
        } else if (newStatus !== "pending") {
          await doc.ref.update({ status: newStatus, xendit_response: xenditData, updated_at: FieldValue.serverTimestamp() });
        }

        results.push({ order_id: orderId, new_status: newStatus, stock_restored: stockRestored });
      } catch (error) {
        const message = error instanceof Error ? error.message : "Unknown";
        results.push({ order_id: orderId, new_status: "error", stock_restored: false, error: message });
      }
    }

    const synced = results.filter((r) => r.new_status !== "pending" && r.new_status !== "error").length;
    return { synced, total_checked: results.length, results };
  }

  // ─── PayPal (unchanged) ──────────────────────────────────────────────────

  static async createPaypalManualTransaction(userId: string, input: CreateTransactionInput & { proof_url?: string }) {
    if (!input.items || input.items.length === 0) throw new Error("Items cannot be empty.");
    if (!input.shipping_area) throw new Error("Shipping area is required.");
    if (!input.customer?.email || !input.customer?.name) throw new Error("Customer name and email are required.");

    const { exchangeRate, shippingCostUsd, shippingCostIdr, orderItems, subtotalUsd, subtotalIdr, totalUsd, totalIdr, orderId } =
      await buildOrderData(input);

    await reduceStock(input.items);

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
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    });

    return { order_id: orderId, status: "pending", total_idr: totalIdr, total_usd: totalUsd };
  }

  static async confirmPaypalOrder(orderId: string) {
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();
    if (!orderDoc.exists) throw new Error(`Order "${orderId}" not found.`);
    const orderData = orderDoc.data()!;
    if (orderData.payment_method !== "paypal_manual") throw new Error("Not a PayPal order.");
    if (orderData.status === "settlement") throw new Error("Already confirmed.");
    await orderRef.update({ status: "settlement", updated_at: FieldValue.serverTimestamp() });
    return { order_id: orderId, status: "settlement" };
  }

  static async rejectPaypalOrder(orderId: string) {
    const orderRef = db.collection(ORDER_HISTORY_COLLECTION).doc(orderId);
    const orderDoc = await orderRef.get();
    if (!orderDoc.exists) throw new Error(`Order "${orderId}" not found.`);
    const orderData = orderDoc.data()!;
    if (orderData.payment_method !== "paypal_manual") throw new Error("Not a PayPal order.");
    if (orderData.status === "cancel") throw new Error("Already rejected.");
    if (orderData.stock_reserved) {
      try { await restoreStock(orderData.items as OrderHistoryItem[]); } catch (e) { console.error("[RejectPaypal] Restore failed:", e); }
    }
    await orderRef.update({ status: "cancel", stock_reserved: false, updated_at: FieldValue.serverTimestamp() });
    return { order_id: orderId, status: "cancel" };
  }
}
