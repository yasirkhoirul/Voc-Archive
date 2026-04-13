import { db } from "../config/firebase";
import {
  CreateTransactionInput,
  OrderHistoryItem,
} from "../models/payment.model";
import { FieldValue } from "firebase-admin/firestore";
// eslint-disable-next-line @typescript-eslint/no-require-imports
const midtransClient = require("midtrans-client");

const ORDER_HISTORY_COLLECTION = "order_history";

function getSnapClient() {
  return new midtransClient.Snap({
    isProduction: process.env.MIDTRANS_IS_PRODUCTION === "true",
    serverKey: process.env.MIDTRANS_SERVER_KEY,
    clientKey: process.env.MIDTRANS_CLIENT_KEY,
  });
}

function getCoreApiClient() {
  return new midtransClient.CoreApi({
    isProduction: process.env.MIDTRANS_IS_PRODUCTION === "true",
    serverKey: process.env.MIDTRANS_SERVER_KEY,
    clientKey: process.env.MIDTRANS_CLIENT_KEY,
  });
}

export class PaymentService {
  /**
   * Creates a Midtrans Snap transaction.
   * 1. Verify product prices from Firestore
   * 2. Fetch exchange rate
   * 3. Fetch shipping cost
   * 4. Create Snap token
   * 5. Save order history
   */
  static async createTransaction(
    userId: string,
    input: CreateTransactionInput
  ) {
    // 1. Validate input
    if (!input.items || input.items.length === 0) {
      throw new Error("Items cannot be empty.");
    }
    if (!input.shipping_area) {
      throw new Error("Shipping area is required.");
    }
    if (!input.customer || !input.customer.email || !input.customer.name) {
      throw new Error("Customer info (name, email) is required.");
    }

    // 2. Fetch exchange rate from Firestore
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

    // 3. Fetch shipping rate
    const shippingDoc = await db
      .collection("settings")
      .doc("shipping_rates")
      .get();
    if (!shippingDoc.exists) {
      throw new Error("Shipping rates have not been configured.");
    }
    const shippingRates = (shippingDoc.data()?.rates as Array<{
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

    // 4. Fetch all product prices from Firestore (server-side verification)
    const productIds = [...new Set(input.items.map((i) => i.product_id))];
    const productMap: Record<string, FirebaseFirestore.DocumentData> = {};

    // Batch fetch in groups of 10
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

    // 5. Calculate prices
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

      // Use discounted price if available, else regular price
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

    // Add shipping as a Midtrans item
    midtransItems.push({
      id: "SHIPPING",
      price: shippingCostIdr,
      quantity: 1,
      name: `Shipping - ${input.shipping_area}`,
    });

    const subtotalIdr = Math.round(subtotalUsd * exchangeRate);
    const totalUsd = subtotalUsd + shippingCostUsd;
    const totalIdr = subtotalIdr + shippingCostIdr;

    // 6. Generate order ID
    const orderId = `VOC-${Date.now()}-${Math.random()
      .toString(36)
      .substring(2, 8)
      .toUpperCase()}`;

    // 7. Create Snap transaction
    const snap = getSnapClient();
    const snapParameter = {
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
    };

    const snapResponse = await snap.createTransaction(snapParameter);
    const snapToken = snapResponse.token as string;
    const redirectUrl = snapResponse.redirect_url as string;

    // 8. Save order history to Firestore
    const orderData = {
      order_id: orderId,
      user_id: userId,
      status: "pending",
      payment_method: "midtrans",
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
    };

    await db.collection(ORDER_HISTORY_COLLECTION).doc(orderId).set(orderData);

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
   */
  static async checkTransactionStatus(orderId: string) {
    const coreApi = getCoreApiClient();
    const statusResponse = await coreApi.transaction.status(orderId);

    const transactionStatus = statusResponse.transaction_status as string;
    const fraudStatus = statusResponse.fraud_status as string;
    const paymentType = statusResponse.payment_type as string;

    let status = "pending";

    if (transactionStatus === "capture") {
      status = fraudStatus === "accept" ? "settlement" : "deny";
    } else if (transactionStatus === "settlement") {
      status = "settlement";
    } else if (
      transactionStatus === "cancel" ||
      transactionStatus === "deny"
    ) {
      status = "cancel";
    } else if (transactionStatus === "expire") {
      status = "expire";
    } else if (transactionStatus === "pending") {
      status = "pending";
    }

    // Update Firestore
    await db.collection(ORDER_HISTORY_COLLECTION).doc(orderId).update({
      status,
      payment_method: paymentType || "midtrans",
      midtrans_response: statusResponse,
      updated_at: FieldValue.serverTimestamp(),
    });

    return {
      order_id: orderId,
      status,
      payment_type: paymentType,
      transaction_status: transactionStatus,
      fraud_status: fraudStatus,
    };
  }

  /**
   * Handles Midtrans notification webhook.
   * Verifies signature and updates order status.
   */
  static async handleNotification(notificationBody: Record<string, unknown>) {
    const coreApi = getCoreApiClient();
    const statusResponse =
      await coreApi.transaction.notification(notificationBody);

    const orderId = statusResponse.order_id as string;
    const transactionStatus = statusResponse.transaction_status as string;
    const fraudStatus = statusResponse.fraud_status as string;
    const paymentType = statusResponse.payment_type as string;

    let status = "pending";

    if (transactionStatus === "capture") {
      status = fraudStatus === "accept" ? "settlement" : "deny";
    } else if (transactionStatus === "settlement") {
      status = "settlement";
    } else if (
      transactionStatus === "cancel" ||
      transactionStatus === "deny"
    ) {
      status = "cancel";
    } else if (transactionStatus === "expire") {
      status = "expire";
    } else if (transactionStatus === "pending") {
      status = "pending";
    }

    // Check if order exists
    const orderDoc = await db
      .collection(ORDER_HISTORY_COLLECTION)
      .doc(orderId)
      .get();
    if (!orderDoc.exists) {
      console.error(`Order ${orderId} not found for notification.`);
      return { status: "error", message: "Order not found." };
    }

    await db.collection(ORDER_HISTORY_COLLECTION).doc(orderId).update({
      status,
      payment_method: paymentType || "midtrans",
      midtrans_response: statusResponse,
      updated_at: FieldValue.serverTimestamp(),
    });

    console.log(
      `[Webhook] Order ${orderId}: status=${status}, payment=${paymentType}`
    );
    return { status: "ok", order_id: orderId, transaction_status: status };
  }
}
