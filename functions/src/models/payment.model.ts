export interface TransactionItem {
  product_id: string;
  quantity: number;
  size: string;
}

export interface CustomerInfo {
  name: string;
  email: string;
  phone: string;
  city: string;
  postal_code: string;
  address: string;
}

export interface CreateTransactionInput {
  items: TransactionItem[];
  shipping_area: string;
  customer: CustomerInfo;
}

export interface OrderHistoryItem {
  product_id: string;
  product_name: string;
  brand_name: string;
  size: string;
  quantity: number;
  price_usd: number;
  discount_percent: number;
  final_price_usd: number;
  final_price_idr: number;
}

export interface OrderHistory {
  order_id: string;
  user_id: string;
  status: string;
  payment_method: string;
  items: OrderHistoryItem[];
  customer: CustomerInfo;
  shipping_area: string;
  shipping_cost_usd: number;
  shipping_cost_idr: number;
  exchange_rate: number;
  subtotal_usd: number;
  subtotal_idr: number;
  total_usd: number;
  total_idr: number;
  snap_token: string;
  redirect_url: string;
  midtrans_response?: Record<string, unknown>;
  created_at: FirebaseFirestore.Timestamp;
  updated_at: FirebaseFirestore.Timestamp;
}
